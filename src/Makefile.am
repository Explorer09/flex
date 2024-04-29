AM_YFLAGS = -d
AM_CPPFLAGS = -DLOCALEDIR=\"$(localedir)\"
AM_CFLAGS = $(WARNINGFLAGS)
LIBS = @LIBS@
pkgconfigdir = @pkgconfigdir@

m4 = @M4@

bin_PROGRAMS = flex
if ENABLE_BOOTSTRAP
noinst_PROGRAMS = stage1flex
if !CROSS
noinst_DATA = stage2compare
endif
endif

if ENABLE_LIBFL
lib_LTLIBRARIES = libfl.la
pkgconfig_DATA = libfl.pc
endif
libfl_la_SOURCES = \
	libmain.c \
	libyywrap.c
libfl_la_LDFLAGS = -version-info @SHARED_VERSION_INFO@

stage1flex_SOURCES = \
	scan.l \
	$(COMMON_SOURCES)

nodist_stage1flex_SOURCES = \
	$(SKELINCLUDES)

if CROSS

stage1flex_SOURCES += \
	../lib/malloc.c \
	../lib/realloc.c

# Suppress build warnings when compiling and linking stage1flex.
stage1flex_CFLAGS =

stage1flex_CPPFLAGS = -DUSE_CONFIG_FOR_BUILD $(AM_CPPFLAGS)

# This also overrides AM_LIBTOOLFLAGS and AM_LDFLAGS
stage1flex_LINK = $(LIBTOOL) $(AM_V_lt) --tag=CC --mode=link $(CC_FOR_BUILD) \
	$(CFLAGS_FOR_BUILD) $(LDFLAGS_FOR_BUILD) -o $@

# Default $(LDADD) would include $(LIBOBJS). Not applicable to stage1flex.
stage1flex_LDADD =

build-flex$(BUILD_EXEEXT):
	@if test "x$(EXEEXT)" != "x$(BUILD_EXEEXT)"; then rm -f stage1flex$(EXEEXT); else :; fi
	@if test "x$(OBJEXT)" != "x$(BUILD_OBJEXT)"; then rm -f stage1flex-*.$(OBJEXT); else :; fi
	@$(MAKE) $(AM_MAKEFLAGS) \
		CC="$(CC_FOR_BUILD)" \
		CPP="$(CPP_FOR_BUILD)" \
		CFLAGS="$(CFLAGS_FOR_BUILD)" \
		CPPFLAGS="$(CPPFLAGS_FOR_BUILD)" \
		LDFLAGS="$(LDFLAGS_FOR_BUILD)" \
		EXEEXT="$(BUILD_EXEEXT)" \
		OBJEXT="$(BUILD_OBJEXT)" \
		stage1flex$(BUILD_EXEEXT)
	@cp stage1flex$(BUILD_EXEEXT) build-flex$(BUILD_EXEEXT)

mostlyclean-local:
	-if test "x$(OBJEXT)" != "x$(BUILD_OBJEXT)"; then rm -f stage1flex-*.$(BUILD_OBJEXT); fi

clean-local:
	-if test "x$(EXEEXT)" != "x$(BUILD_EXEEXT)"; then rm -f stage1flex$(BUILD_EXEEXT); fi

stage1flex$(EXEEXT): $(stage1flex_OBJECTS) $(stage1flex_DEPENDENCIES) $(EXTRA_stage1flex_DEPENDENCIES)
	@rm -f stage1flex$(EXEEXT)
	@if test "x$(CC)" = "x$(CC_FOR_BUILD)" && "x$(CPP)" = "x$(CPP_FOR_BUILD)"; then \
		:
	else \
		# Delete object files as they might be built with a wrong compiler
		rm -f stage1flex-*.$(OBJEXT) \
		echo "error: stage1flex must be built with a native compiler" 1>&2 \
		exit 1 \
	fi
	$(AM_V_CCLD)$(stage1flex_LINK) $(stage1flex_OBJECTS) $(stage1flex_LDADD)

endif

flex_SOURCES = \
	$(COMMON_SOURCES)

nodist_flex_SOURCES = \
	$(SKELINCLUDES)

if ENABLE_BOOTSTRAP
nodist_flex_SOURCES += stage1scan.c
else
flex_SOURCES += scan.l
endif

COMMON_SOURCES = \
	buf.c \
	ccl.c \
	dfa.c \
	ecs.c \
	filter.c \
	flexdef.h \
	flexint.h \
	flexint_shared.h \
	gen.c \
	main.c \
	misc.c \
	nfa.c \
	options.c \
	options.h \
	parse.y \
	regex.c \
	scanflags.c \
	scanopt.c \
	scanopt.h \
	skeletons.c \
	sym.c \
	tables.c \
	tables.h \
	tables_shared.c \
	tables_shared.h \
	tblcmp.c \
	version.h \
	yylex.c

LDADD = $(LIBOBJS) @LIBINTL@

$(LIBOBJS): $(LIBOBJDIR)$(am__dirstamp)

include_HEADERS = \
	FlexLexer.h

EXTRA_DIST = \
	c99-flex.skl \
	cpp-flex.skl \
	go-flex.skl \
	mkskel.sh \
	gettext.h \
	chkskel.sh

MOSTLYCLEANFILES = \
	$(SKELINCLUDES) \
	stage1scan.c \
	stage2scan.c \
	stage2compare

CLEANFILES = build-flex$(BUILD_EXEEXT) stage1flex$(EXEEXT)

SKELINCLUDES = \
	cpp-flex.h \
	c99-flex.h \
	go-flex.h

cpp-flex.h: cpp-flex.skl mkskel.sh flexint_shared.h tables_shared.h tables_shared.c
	$(SHELL) $(srcdir)/mkskel.sh cpp $(srcdir) $(m4) $(VERSION) > $@.tmp
	$(SHELL) $(srcdir)/chkskel.sh $@.tmp
	mv -f $@.tmp $@

c99-flex.h: c99-flex.skl mkskel.sh
	$(SHELL) $(srcdir)/mkskel.sh c99 $(srcdir) $(m4) $(VERSION) > $@.tmp
	$(SHELL) $(srcdir)/chkskel.sh $@.tmp
	mv -f $@.tmp $@

go-flex.h: go-flex.skl mkskel.sh
	$(SHELL) $(srcdir)/mkskel.sh go $(srcdir) $(m4) $(VERSION) > $@.tmp
	$(SHELL) $(srcdir)/chkskel.sh $@.tmp
	mv -f $@.tmp $@

# The input and output file names are fixed for deterministic scanner
# generation. If scan.l is not modified by builders, stage1scan.c should
# be bit-identical to the scan.c pregenerated on release.
stage1scan.c: scan.l build-flex$(BUILD_EXEEXT)
	( cd $(srcdir) && $(abs_builddir)/build-flex$(BUILD_EXEEXT) \
	  $(AM_LFLAGS) $(LFLAGS) -o scan.c -t scan.l ) >$@ || \
	{ s=$$?; rm -f $@; exit $$s; }

# Unlike stage1scan.c, we leave stage2scan.c intact when the generation
# fails. This allow users to examine generation errors.
stage2scan.c: scan.l flex$(EXEEXT) stage1scan.c
	( cd $(srcdir) && $(abs_builddir)/flex$(EXEEXT) \
	  $(AM_LFLAGS) $(LFLAGS) -o scan.c -t scan.l ) >$@

stage2compare: stage1scan.c
	@rm -f stage2scan.c; \
	$(MAKE) $(AM_MAKEFLAGS) stage2scan.c; \
	echo Comparing stage1scan.c and stage2scan.c; \
	cmp stage1scan.c stage2scan.c || { \
	  s=$$?; \
	  echo "Bootstrap comparison failure!"; \
	  exit $$s; \
	}; \
	echo Comparison successful.; \
	echo success >$@

dist-hook: scan.l flex$(EXEEXT)
	chmod u+w $(distdir) && \
	chmod u+w $(distdir)/scan.c && \
	( cd $(srcdir) && $(abs_builddir)/flex$(EXEEXT) \
	  -o scan.c -t scan.l ) >scan.c && \
	mv -f scan.c $(distdir)

# make needs to be told to make inclusions so that parallelized runs will
# not fail.

stage1flex-skeletons.$(OBJEXT): $(SKELINCLUDES)
skeletons.$(OBJEXT): $(SKELINCLUDES)

stage1flex-main.$(OBJEXT): parse.h
main.$(OBJEXT): parse.h

stage1flex-yylex.$(OBJEXT): parse.h
yylex.$(OBJEXT): parse.h

stage1flex-scan.$(OBJEXT): parse.h
stage1scan.$(OBJEXT): parse.h
scan.$(OBJEXT): parse.h

# Run GNU indent on sources. Don't run this unless all the sources compile cleanly.
#
# Whole idea:
#   1. Check for .indent.pro, otherwise indent will use unknown
#      settings, or worse, the GNU defaults.)
#   2. Check that this is GNU indent.
#   3. Make sure to process only the NON-generated .c and .h files.
#   4. Run indent twice per file. The first time is a test.
#      Otherwise, indent overwrites your file even if it fails!
indentfiles = \
	buf.c \
	ccl.c \
	dfa.c \
	ecs.c \
	scanflags.c \
	filter.c \
	flexdef.h \
	gen.c \
	libmain.c \
	libyywrap.c \
	main.c \
	misc.c \
	nfa.c \
	options.c \
	options.h \
	regex.c \
	scanopt.c \
	scanopt.h \
	sym.c \
	tables.c \
	tables.h \
	tables_shared.c \
	tables_shared.h \
	tblcmp.c

indent: $(top_srcdir)/.indent.pro
	cd $(top_srcdir) && \
	for f in $(indentfiles); do \
		f=src/$$f; \
		echo indenting $$f; \
		INDENT_PROFILE=.indent.pro $(INDENT) <$$f >/dev/null && \
		INDENT_PROFILE=.indent.pro $(INDENT) $$f || \
		echo $$f FAILED to indent; \
	done;

.PHONY: indent
