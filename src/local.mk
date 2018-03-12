AM_YFLAGS = -d
AM_CPPFLAGS = -DLOCALEDIR=\"$(localedir)\"
AM_CFLAGS = $(WARNINGFLAGS)
LIBS = @LIBS@
pkgconfigdir = @pkgconfigdir@

m4 = @M4@

if ENABLE_LIBFL
lib_LTLIBRARIES = src/libfl.la
pkgconfig_DATA = src/libfl.pc
endif
src_libfl_la_SOURCES = \
	src/libmain.c \
	src/libyywrap.c
src_libfl_la_LDFLAGS = -version-info @SHARED_VERSION_INFO@

bin_PROGRAMS = src/flex

EXTRA_PROGRAMS = src/build-flex src/stage1flex

# All object file names and build rules for this build-time flex program will
# be transformed in a late config.status stage in order to enable the build
# system's native toolchain. The build-*.$(OBJEXT) filenames,
# $(src_build_flex_CPPFLAGS), and $(src_build_flex_CFLAGS) are all keywords to
# the transforming (sed) script. See configure.ac for details.
src_build_flex_SHORTNAME = build
src_build_flex_CPPFLAGS = $(AM_CPPFLAGS) -DUSE_CONFIG_FOR_BUILD
# Suppress the warning flags when compiling and linking the build-time flex.
src_build_flex_CFLAGS =
# Default $(LDADD) would include $(LIBOBJS). Not applicable to build-time flex.
src_build_flex_LDADD =

src_build_flex_SOURCES = \
	lib/malloc.c \
	lib/realloc.c \
	src/scan.l \
	$(common_sources)

src_stage1flex_SOURCES = \
	src/scan.l \
	$(common_sources)

src_flex_SOURCES = \
	$(common_sources)

if ENABLE_BOOTSTRAP
nodist_src_flex_SOURCES = src/stage1scan.c
else
src_flex_SOURCES += src/scan.l
endif

common_sources = \
	src/buf.c \
	src/ccl.c \
	src/dfa.c \
	src/ecs.c \
	src/filter.c \
	src/flexdef.h \
	src/flexint.h \
	src/flexint_shared.h \
	src/gen.c \
	src/main.c \
	src/misc.c \
	src/nfa.c \
	src/options.c \
	src/options.h \
	src/parse.y \
	src/regex.c \
	src/scanflags.c \
	src/scanopt.c \
	src/scanopt.h \
	src/skel.c \
	src/sym.c \
	src/tables.c \
	src/tables.h \
	src/tables_shared.c \
	src/tables_shared.h \
	src/tblcmp.c \
	src/version.h \
	src/yylex.c

LDADD = $(LIBOBJS) @LIBINTL@

$(LIBOBJS): $(LIBOBJDIR)$(am__dirstamp)

include_HEADERS = \
	src/FlexLexer.h

EXTRA_DIST += \
	src/flex.skl \
	src/mkskel.sh \
	src/gettext.h

MOSTLYCLEANFILES += src/stage1scan.c

CLEANFILES += src/build-flex$(BUILD_EXEEXT) src/stage1flex$(EXEEXT)

MAINTAINERCLEANFILES += src/skel.c

skel_dependencies = \
	src/flex.skl \
	src/flexint_shared.h \
	src/tables_shared.c \
	src/tables_shared.h

src/skel.c: src/mkskel.sh $(skel_dependencies)
	$(SHELL) $(srcdir)/src/mkskel.sh $(srcdir)/src $(m4) $(VERSION) > $@.tmp
	mv -f $@.tmp $@

# Ensure the input and output file names are fixed so that the generated
# results are comparable.
if CROSS
src/stage1scan.c: src/scan.l src/build-flex$(BUILD_EXEEXT)
	( cd $(srcdir)/src && \
	  $(abs_builddir)/src/build-flex$(BUILD_EXEEXT) $(AM_LFLAGS) \
	  -o scan.c -t $(LFLAGS) scan.l ) >$@
else
src/stage1scan.c: src/scan.l src/stage1flex$(EXEEXT)
	( cd $(srcdir)/src && \
	  $(abs_builddir)/src/stage1flex$(EXEEXT) $(AM_LFLAGS) -o scan.c -t \
	  $(LFLAGS) scan.l ) >$@
endif

dist-hook: src-dist-hook

src-dist-hook: src/scan.l src/flex$(EXEEXT)
	chmod u+w $(distdir)/src && \
	( cd $(srcdir)/src && $(abs_builddir)/src/flex$(EXEEXT) -o scan.c -t \
	  scan.l ) >src/scan.c && \
	mv -f src/scan.c $(distdir)/src

# make needs to be told to make parse.h so that parallelized runs will
# not fail.

src/build-main.$(BUILD_OBJEXT): src/parse.h
src/main.$(OBJEXT): src/parse.h

src/build-yylex.$(BUILD_OBJEXT): src/parse.h
src/yylex.$(OBJEXT): src/parse.h

src/build-scan.$(BUILD_OBJEXT): src/parse.h
src/stage1scan.$(OBJEXT): src/parse.h
src/scan.$(OBJEXT): src/parse.h

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
	src/buf.c \
	src/ccl.c \
	src/dfa.c \
	src/ecs.c \
	src/scanflags.c \
	src/filter.c \
	src/flexdef.h \
	src/gen.c \
	src/libmain.c \
	src/libyywrap.c \
	src/main.c \
	src/misc.c \
	src/nfa.c \
	src/options.c \
	src/options.h \
	src/regex.c \
	src/scanopt.c \
	src/scanopt.h \
	src/sym.c \
	src/tables.c \
	src/tables.h \
	src/tables_shared.c \
	src/tables_shared.h \
	src/tblcmp.c

indent: .indent.pro
	for f in $(indentfiles); do \
		echo indenting $$f; \
		INDENT_PROFILE=.indent.pro $(INDENT) <$$f >/dev/null && \
		INDENT_PROFILE=.indent.pro $(INDENT) $$f || \
		echo $$f FAILED to indent; \
	done;

.PHONY: src-dist-hook indent
