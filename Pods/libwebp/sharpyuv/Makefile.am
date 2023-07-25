AM_CPPFLAGS += -I$(top_builddir) -I$(top_srcdir)
AM_CPPFLAGS += -I$(top_builddir)/src -I$(top_srcdir)/src
noinst_LTLIBRARIES =
noinst_LTLIBRARIES += libsharpyuv.la
noinst_LTLIBRARIES += libsharpyuv_sse2.la
noinst_LTLIBRARIES += libsharpyuv_neon.la

noinst_HEADERS =
noinst_HEADERS += ../src/webp/types.h
noinst_HEADERS += ../src/dsp/cpu.h

libsharpyuv_sse2_la_SOURCES =
libsharpyuv_sse2_la_SOURCES += sharpyuv_sse2.c
libsharpyuv_sse2_la_CPPFLAGS = $(libsharpyuv_la_CPPFLAGS)
libsharpyuv_sse2_la_CFLAGS = $(AM_CFLAGS) $(SSE2_FLAGS)

libsharpyuv_neon_la_SOURCES =
libsharpyuv_neon_la_SOURCES += sharpyuv_neon.c
libsharpyuv_neon_la_CPPFLAGS = $(libsharpyuv_la_CPPFLAGS)
libsharpyuv_neon_la_CFLAGS = $(AM_CFLAGS) $(NEON_FLAGS)

libsharpyuv_la_SOURCES =
libsharpyuv_la_SOURCES += sharpyuv_csp.c sharpyuv_csp.h
libsharpyuv_la_SOURCES += sharpyuv_dsp.c sharpyuv_dsp.h
libsharpyuv_la_SOURCES += sharpyuv_gamma.c sharpyuv_gamma.h
libsharpyuv_la_SOURCES += sharpyuv.c sharpyuv.h

libsharpyuv_la_CPPFLAGS = $(AM_CPPFLAGS)
libsharpyuv_la_LDFLAGS =
libsharpyuv_la_LIBADD =
libsharpyuv_la_LIBADD += libsharpyuv_sse2.la
libsharpyuv_la_LIBADD += libsharpyuv_neon.la

noinst_PROGRAMS =
