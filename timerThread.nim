# !!! IMPORTANT !!! This program dosn't work well.
# ---
# timerThread.nim --- Timer Thread module
# ---
import wNim/[wApp, wFrame]
import winim/lean

type
    TTimer* = ref object
        id: PTP_TIMER
        fn: PTP_TIMER_CALLBACK
        interval: int
        fStart: bool
        window: wFrame

proc Timer*(window: wFrame = nil, id: int, timerProc: PTP_TIMER_CALLBACK = nil, interval = 100):TTimer =
    result = new TTimer
    result.fn = timerProc
    result.interval = interval
    result.window = window
    result.fStart = false

proc start*(self: TTimer) =
    if not self.fStart:
        self.fStart = true
        var ulStartDelay: ULARGE_INTEGER
        #ulStartDelay.QuadPart = -30000000.ULONGLONG # 3sec = 100nsec x (-30000000)
        ulStartDelay.QuadPart = -1.ULONGLONG
        var ftst: FILETIME
        ftst.dwHighDateTime = ulStartDelay.HighPart
        ftst.dwLowDateTime = ulStartDelay.LowPart
        self.id = CreateThreadpoolTimer(self.fn, nil, nil)
        if self.id == nil:
            echo "Create Error!: " & $GetLastError()
            quit 0
        else:
            SetThreadPoolTimer(self.id,cast[PFILETIME](ftst.addr),self.interval.DWORD,0)

proc stop*(self: TTimer) =
    if self.fStart:
        self.fStart = false
        if self.id != nil:
            SetThreadPoolTimer(self.id,nil,0,0)
            WaitForThreadpoolTimerCallbacks(self.id,true)
            CloseThreadpoolTimer(self.id)
            self.id = nil

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
    import wNim/[wApp, wFrame, wEvent, wPanel, wButton]
    import winim/lean

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

    proc timer1Proc(Instance: PTP_CALLBACK_INSTANCE, Context: PVOID, Timer: PTP_TIMER): VOID {.stdcall.} =
        var count {.global.} = 0
        count += 1
        btn1.label = "Timer1:    " & $count
    proc timer2Proc(Instance: PTP_CALLBACK_INSTANCE, Context: PVOID, Timer: PTP_TIMER): VOID {.stdcall.} =
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



