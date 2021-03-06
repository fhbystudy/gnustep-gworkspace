AC_PREREQ(2.52)
AC_INIT(gworkspace, 0.9.2)

if test -z "$GNUSTEP_MAKEFILES"; then
  AC_MSG_ERROR([You must run the GNUstep initialization script first!])
fi

#--------------------------------------------------------------------
# Use config.guess, config.sub and install-sh provided by gnustep-make
#--------------------------------------------------------------------
AC_CHECK_HEADERS(dir.h unistd.h)
AC_CHECK_FUNCS(getpwnam getpwuid geteuid getlogin)

AC_CONFIG_AUX_DIR([$GNUSTEP_MAKEFILES])

AC_CONFIG_SUBDIRS([FSNode DBKit GWorkspace Tools Inspector Operation Recycler])


AC_ARG_ENABLE(gwmetadata,
  [  --enable-gwmetadata     Enable GWMetadata], , [enable_gwmetadata=no])

if test "x$enable_gwmetadata" = "xyes"; then
  AC_CONFIG_SUBDIRS([GWMetadata])
  BUILD_GWMETADATA=1
else
  BUILD_GWMETADATA=0
fi
AC_SUBST(BUILD_GWMETADATA)

#--------------------------------------------------------------------
# Debug logging
#--------------------------------------------------------------------
AC_ARG_ENABLE(debug_log,
  [  --enable-debug-log      Enable debug logging],,
      enable_debug_log=no)

if test "$enable_debug_log" = "yes"; then
 GW_DEBUG_LOG=1
else
 GW_DEBUG_LOG=0
fi

AC_DEFINE_UNQUOTED([GW_DEBUG_LOG], [$GW_DEBUG_LOG], [debug logging])

#--------------------------------------------------------------------
# fswatcher-inotify
#--------------------------------------------------------------------
AC_ARG_WITH(inotify,
  [  --with-inotify  Build fswatcher-inotify],
  with_inotify=yes, with_inotify=no)
  
AC_SUBST(with_inotify)


AC_CONFIG_FILES([GNUmakefile])
AC_OUTPUT
