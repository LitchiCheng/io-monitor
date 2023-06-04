TARGET=iotop

SRCS:=$(wildcard src/*.c)
OBJS:=$(patsubst %c,%o,$(patsubst src/%,bld/%,$(SRCS)))
DEPS:=$(OBJS:.o=.d)

ifndef NO_FLTO
CFLAGS?=-O3 -fno-stack-protector -mno-stackrealign
CFLAGS+=-flto=auto
else
CFLAGS?=-O3 -fno-stack-protector -mno-stackrealign
endif

ifdef GCCFANALIZER
CFLAGS+=-fanalyzer
endif

INSTALL?=install

# for glibc < 2.17, -lrt is required for clock_gettime
NEEDLRT:=$(shell if $(CC) -E glibcvertest.h -o -|grep IOTOP_NEED_LRT|grep -q yes;then echo need; fi)
# some architectures do not have -mno-stackrealign
HAVESREA:=$(shell if $(CC) -mno-stackrealign -xc -c /dev/null -o /dev/null >/dev/null 2>/dev/null;then echo yes;else echo no;fi)
# old comiplers do not have -Wdate-time
HAVEWDTI:=$(shell if $(CC) -Wdate-time -xc -c /dev/null -o /dev/null >/dev/null 2>/dev/null;then echo yes;else echo no;fi)

MYCFLAGS:=$(CPPFLAGS) $(CFLAGS) $(NCCC) -Wall -Wextra -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 --std=gnu89 -fPIE
ifeq ("$(HAVESREA)","no")
MYCFLAGS:=$(filter-out -mno-stackrealign,$(MYCFLAGS))
endif
ifeq ("$(HAVEWDTI)","no")
MYCFLAGS:=$(filter-out -Wdate-time,$(MYCFLAGS))
endif

MYLIBS:=$(NCLD) $(LIBS)
MYLDFLAGS:=$(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -fPIE -pie
ifeq ("$(NEEDLRT)","need")
MYLDFLAGS+=-lrt
endif
STRIP?=strip

PREFIX?=$(DESTDIR)/usr

ifeq ("$(V)","1")
Q:=
E:=@true
else
Q:=@
E:=@echo
endif

all: $(TARGET)

$(TARGET): $(OBJS)
	$(E) LD $@
	$(Q)$(CC)  $(INCLUDE) -o $@ $(MYLDFLAGS) $^ $(MYLIBS)

bld/%.o: src/%.c bld/.mkdir
	$(E) DE $@
	$(Q)$(CC) $(MYCFLAGS) -MM -MT $@ -MF $(patsubst %.o,%.d,$@) $<
	$(E) CC $@
	$(Q)$(CC) $(MYCFLAGS) -c -o $@ $<

clean:
	$(E) CLEAN
	$(Q)rm -rf ./bld $(TARGET)

bld/.mkdir:
	$(Q)mkdir -p bld
	$(Q)touch bld/.mkdir

-include $(DEPS)

.PHONY: all clean
