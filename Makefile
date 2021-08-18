CC ?= cc
CFLAGS ?=
LDFLAGS ?=
TMPDIR ?= /tmp
ATOMROOT  ?= .
ATOMC     ?= ./atomc
ATOM      ?= ./atom
ATOMREPO ?= https://github.com/atomlang/atomc
ATOMCREPO ?= https://github.com/atomlang/tccbin

ATOMFILE := atom.c
TMPTCC := $(ATOMROOT)/thirdparty/tcc
TCCOS := unknown
TCCARCH := unknown
GITCLEANPULL := git clean -xf && git pull --quiet
GITFASTCLONE := git clone --depth 1 --quiet --single-branch

_SYS := $(shell uname 2>/dev/null || echo Unknown)
_SYS := $(patsubst MSYS%,MSYS,$(_SYS))
_SYS := $(patsubst MINGW%,MinGW,$(_SYS))

ifneq ($(filter $(_SYS),MSYS MinGW),)
WIN32 := 1
ATOM:=./atom.exe
endif

ifeq ($(_SYS),Linux)
LINUX := 1
TCCOS := linux
endif

ifeq ($(_SYS),Darwin)
MAC := 1
TCCOS := macos
endif

ifeq ($(_SYS),FreeBSD)
TCCOS := freebsd
LDFLAGS += -lexecinfo
endif

ifeq ($(_SYS),NetBSD)
TCCOS := netbsd
LDFLAGS += -lexecinfo
endif

ifdef ANDROID_ROOT
ANDROID := 1
undefine LINUX
TCCOS := android
endif

ifdef WIN32
TCCOS := windows
ATOMCFILE := atom_win.c
endif

TCCARCH := $(shell uname -m 2>/dev/null || echo unknown)

ifeq ($(TCCARCH),x86_64)
	TCCARCH := amd64
else
ifneq ($(filter x86%,$(TCCARCH)),)
	TCCARCH := i386
else
ifeq ($(TCCARCH),arm64)
	TCCARCH := arm64
else
ifneq ($(filter arm%,$(TCCARCH)),)
	TCCARCH := arm

endif
endif
endif
endif

.PHONY: all clean fresh_atomc fresh_tcc

ifdef prod
ATOMFLAGS+=-prod
endif

all: latest_atomc latest_tcc
ifdef WIN32
	$(CC) $(CFLAGS) -std=c99 -municode -w -o $(ATOM) $(ATOMC)/$(ATOMCFILE) $(LDFLAGS)
	$(ATOM) -o atomv2.exe $(ATOMFLAGS) cmd/atom
	move /y atomv2.exe atom.exe
else
	$(CC) $(CFLAGS) -std=gnu99 -w -o $(ATOM) $(ATOMC)/$(ATOMCFILE) -lm -lpthread $(LDFLAGS)
	$(ATOM) -o atomv2.exe $(ATOMFLAGS) cmd/atom
	mv -f atomv2.exe atom
endif
	@echo "atom has been successfully built"
	@$(ATOM) -version

clean:
	rm -rf $(TMPTCC)
	rm -rf $(ATOMC)

ifndef local
latest_atomc: $(ATOMC)/.git/config
	cd $(ATOMC) && $(GITCLEANPULL)
else
latest_atomc:
	@echo "Using local atomc"
endif

fresh_atomc:
	rm -rf $(ATOMC)
	$(GITFASTCLONE) $(ATOMCREPO) $(ATOMC)

ifndef local
latest_tcc: $(TMPTCC)/.git/config
	cd $(TMPTCC) && $(GITCLEANPULL)
else
latest_tcc:
	@echo "Using local tcc"
endif

fresh_tcc:
	rm -rf $(TMPTCC)
ifndef local

ifneq (,$(findstring thirdparty-$(TCCOS)-$(TCCARCH), $(shell git ls-remote --heads $(TCCREPO) | sed 's/^[a-z0-9]*\trefs.heads.//')))
	$(GITFASTCLONE) --branch thirdparty-$(TCCOS)-$(TCCARCH) $(TCCREPO) $(TMPTCC)
else
	@echo 'Pre-built TCC not available for thirdparty-$(TCCOS)-$(TCCARCH) at $(TCCREPO), will use the system compiler: $(CC)'
	$(GITFASTCLONE) --branch thirdparty-unknown-unknown $(TCCREPO) $(TMPTCC)
endif
else
	@echo "Using local tccbin"
endif

$(TMPTCC)/.git/config:
	$(MAKE) fresh_tcc

$(ATOMC)/.git/config:
	$(MAKE) fresh_atom

asan:
	$(MAKE) all CFLAGS='-fsanitize=address,undefined'

selfcompile:
	$(ATOM) -cg -o atom cmd/atom

selfcompile-static:
	$(ATOM) -cg -cflags '--static' -o atom-static cmd/atom

install:
	@echo 'Please use `sudo ./atom symlink` instead.'
