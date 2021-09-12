TARGET= timer
#TARGET= timerThread

#TOOLCHAIN = clang
TOOLCHAIN ?= tcc

ifneq ($(TOOLCHAIN),tcc)
OPT += -d:danger -d:strip
OPT += --opt:size
else
TOOLCHAIN = tcc
endif

OPT += --app:gui
OPT += --showAllMismatches:on
OPT += --threads:on
#OPT += -d:useWinXP
OPT += --cc:$(TOOLCHAIN)

ifneq ($(TOOLCHAIN),tcc)
OPT_GCC +=--passC:-ffunction-sections --passC:-fdata-sections
OPT_GCC +=--passL:-Wl,--gc-sections
OPT += $(OPT_GCC)
endif

DEST_EXE = $(addsuffix .exe,$(TARGET))

all:$(DEST_EXE)


#NIMCACHE= x:/.nimcache
NIMCACHE=.nimcache_$@

%.exe: %.nim Makefile
	nim c $(OPT) --nimcache:$(NIMCACHE) $(<)
	-@size $(@)
	-@ls -al $@
check:
	nim check $(OPT) --nimcache:$(NIMCACHE) $(TARGET)

.PHONY: run clean

run: all
	$(TARGET).exe

clean:
	-@rm $(DEST_EXE)
	-@rm -fr .nimcache_*
	-@rm -fr .nimcache
	-@rm -fr $(NIMCACHE)

