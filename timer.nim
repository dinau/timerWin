# ---
# timer.nim --- Timer module
# ---
import wNim/[wApp, wFrame]
import winim/lean

type
    TTimer* = ref object
        id: UINT_PTR
        fn: TIMERPROC
        interval: int
        fStart: bool
        window: wFrame

proc Timer*(window: wFrame = nil, id: int, timerProc: TIMERPROC = nil, interval = 100):TTimer =
    result = new TTimer
    result.fn = timerProc
    result.id = cast[UINT_PTR](id)
    result.interval = interval
    result.window = window
    result.fStart = false

proc start*(self: TTimer) =
    if not self.fStart:
        self.fStart = true
        if self.window != nil:
            SetTimer(self.window.handle, self.id, self.interval.UINT, self.fn)
        else:
            self.id = SetTimer(cast[HWND](nil), self.id, self.interval.UINT, self.fn)

proc stop*(self: TTimer) =
    if self.fStart:
        self.fStart = false
        if self.window != nil:
            KillTimer(self.window.handle, self.id)
        else:
            KillTimer(cast[HWND](nil), self.id)

proc reStart*(self: TTimer,interval:int) =
    self.stop()
    self.interval = interval
    self.start()

proc isAlive*(self: TTimer): bool =
    return self.fStart

proc toggle*(self: TTimer) =
    if self.fStart: self.stop() else: self.start()

#proc TimerCallback(Instance: PTP_CALLBACK_INSTANCE, Context: PVOID, Timer: PTP_TIMER): VOID {.stdcall.}

when isMainModule:
    # -------------------
    # Test program
    # -------------------
    import wNim/[wEvent, wPanel, wButton]

    # --- GUI definition
    let app = App(wSystemDpiAware)
    let fmMain = Frame(title = "Timer test", size = (500, 100))
    let panel = Panel(fmMain)
    let btn1 = Button(panel, size = (200, 50))
    let btn2 = Button(panel, size = (200, 50))

    # layouter
    proc layout() =
        panel.autolayout """
            h:|~[btn1]~[btn2]~|
            v:|~[btn1,btn2]~|
        """

    panel.wEvent_Size do ():
        layout()

    # --- Timer definition
    type timerID = enum
        idTimer1 = 10000, idTimer2

    proc timer1Proc(hWnd: HWND, message: UINT, pIdTimer: UINT_PTR, dwTime: DWORD): VOID{.stdcall.} =
        var count {.global.} = 0
        count += 1
        btn1.label = "Timer1:    " & $count
    proc timer2Proc(hWnd: HWND, message: UINT, pIdTimer: UINT_PTR, dwTime: DWORD): VOID{.stdcall.} =
        var count {.global.} = 0
        count += 1
        btn2.label = "Timer2:    " & $count

    let timer1 = Timer(id = idTimer1.int, interval = 500,
            timerProc = timer1Proc)

    let timer2 = Timer(fmMain, id = idTimer2.int, interval = 80,
            timerProc = timer2Proc)

    # --- Event procs
    btn1.wEvent_Button do (event: wEvent):
        if timer1.isAlive(): timer1.stop() else: timer1.start()
        #timer1.toggle

    btn2.wEvent_Button do (event: wEvent):
        if timer2.isAlive(): timer2.stop() else: timer2.start()
        #timer2.toggle

    # --- Main proc
    layout()

    timer1.start()
    timer2.start()

    fmMain.center()
    fmMain.show()

    app.mainLoop()

