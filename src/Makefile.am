AM_YFLAGS = -d
AM_CPPFLAGS = -DLOCALEDIR=\"$(localedir)\"
AM_CFLAGS = $(WARNINGFLAGS)
LIBS = @LIBS@
pkgconfigdir = @pkgconfigdir@

m4 = @M4@

if ENABLE_LIBFL
lib_LTLIBRARIES = libfl.la
pkgconfig_DATA = libfl.pc
endif
libfl_la_SOURCES = \
	libmain.c \
	libyywrap.c
libfl_la_LDFLAGS = -version-info @SHARED_VERSION_INFO@

bin_PROGRAMS = flex

EXTRA_PROGRAMS = build-flex stage1flex

if ENABLE_BOOTSTRAP
if !CROSS
noinst_DATA = stage2compare
endif
endif

# All object file names and build rules for this build-time flex program will
# be transformed in a late config.status stage in order to enable the build
# system's native toolchain. The build-*.$(OBJEXT) filenames,
# $(build_flex_CPPFLAGS), and $(build_flex_CFLAGS) are all keywords to the
# transforming (sed) script. See configure.ac for details.
build_flex_SHORTNAME = build
build_flex_CPPFLAGS = $(AM_CPPFLAGS) -DUSE_CONFIG_FOR_BUILD
# Suppress the warning flags when compiling and linking the build-time flex.
build_flex_CFLAGS =
# Default $(LDADD) would include $(LIBOBJS). Not applicable to build-time flex.
build_flex_LDADD =

build_flex_SOURCES = \
	../lib/malloc.c \
	../lib/realloc.c \
	scan.l \
	$(COMMON_SOURCES)

stage1flex_SOURCES = \
	scan.l \
	$(COMMON_SOURCES)

nodist_stage1flex_SOURCES = \
	$(SKELINCLUDES)

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
if CROSS
stage1scan.c: scan.l build-flex$(BUILD_EXEEXT)
	( cd $(srcdir) && $(abs_builddir)/build-flex$(BUILD_EXEEXT) \
	  $(AM_LFLAGS) $(LFLAGS) -o scan.c -t scan.l ) >$@ || \
	{ s=$$?; rm -f $@; exit $$s; }
else
stage1scan.c: scan.l stage1flex$(EXEEXT)
	( cd $(srcdir) && $(abs_builddir)/stage1flex$(EXEEXT) \
	  $(AM_LFLAGS) $(LFLAGS) -o scan.c -t scan.l ) >$@ || \
	{ s=$$?; rm -f $@; exit $$s; }
endif

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

build-skeletons.$(BUILD_OBJEXT): $(SKELINCLUDES)
skeletons.$(OBJEXT): $(SKELINCLUDES)

build-main.$(BUILD_OBJEXT): parse.h
main.$(OBJEXT): parse.h

build-yylex.$(BUILD_OBJEXT): parse.h
yylex.$(OBJEXT): parse.h

build-scan.$(BUILD_OBJEXT): parse.h
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
