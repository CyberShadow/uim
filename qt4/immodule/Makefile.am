.PHONY: mocclean FORCE

# Makefile.qmake is only exist when --enable-qt4-immodule
if QT4_IMMODULE
all clean mocclean install uninstall:
	$(MAKE) $(AM_MAKEFLAGS) -f Makefile.qmake INSTALL_ROOT=$(DESTDIR) $@
endif

# *.pro is required to run Makefile.qmake. So distclean-am is deferred.
distclean:
if QT4_IMMODULE
	$(MAKE) $(AM_MAKEFLAGS) -f Makefile.qmake $@
	$(MAKE) $(AM_MAKEFLAGS) distclean-am
endif
	-rm -f Makefile quiminputcontextplugin.pro

FORCE:

EXTRA_DIST = INDENT \
	     quiminputcontextplugin.pro.in \
	     quiminputcontext_with_slave.h \
	     quiminputcontext_with_slave.cpp

EXTRA_DIST += candidatewindowproxy.h \
              caretstateindicator.h \
              plugin.h \
              qhelpermanager.h \
              qtextutil.h \
              quiminfomanager.h \
              quiminputcontext.h \
              quiminputcontext_compose.h

EXTRA_DIST += candidatewindowproxy.cpp \
              caretstateindicator.cpp \
              plugin.cpp \
              qhelpermanager.cpp \
              qtextutil.cpp \
              quiminfomanager.cpp \
              quiminputcontext.cpp \
              quiminputcontext_compose.cpp
