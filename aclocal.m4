dnl Macros used to build the Wine configure script
dnl
dnl Copyright 2002 Alexandre Julliard
dnl
dnl This library is free software; you can redistribute it and/or
dnl modify it under the terms of the GNU Lesser General Public
dnl License as published by the Free Software Foundation; either
dnl version 2.1 of the License, or (at your option) any later version.
dnl
dnl This library is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl Lesser General Public License for more details.
dnl
dnl You should have received a copy of the GNU Lesser General Public
dnl License along with this library; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
dnl
dnl As a special exception to the GNU Lesser General Public License,
dnl if you distribute this file as part of a program that contains a
dnl configuration script generated by Autoconf, you may include it
dnl under the same distribution terms that you use for the rest of
dnl that program.

dnl **** Get the ldd program name; used by WINE_GET_SONAME ****
dnl
dnl Usage: WINE_PATH_LDD
dnl
AC_DEFUN([WINE_PATH_LDD],[AC_PATH_PROG(LDD,ldd,true,/sbin:/usr/sbin:$PATH)])

dnl **** Extract the soname of a library ****
dnl
dnl Usage: WINE_CHECK_SONAME(library, function, [action-if-found, [action-if-not-found, [other_libraries, [pattern]]]])
dnl
AC_DEFUN([WINE_CHECK_SONAME],
[AC_REQUIRE([WINE_PATH_LDD])dnl
AS_VAR_PUSHDEF([ac_Lib],[ac_cv_lib_soname_$1])dnl
m4_pushdef([ac_lib_pattern],m4_default([$6],[lib$1]))dnl
AC_MSG_CHECKING([for -l$1])
AC_CACHE_VAL(ac_Lib,
[ac_check_soname_save_LIBS=$LIBS
LIBS="-l$1 $5 $LIBS"
  AC_LINK_IFELSE([AC_LANG_CALL([], [$2])],
  [case "$LIBEXT" in
    dll) AS_VAR_SET(ac_Lib,[`$ac_cv_path_LDD conftest.exe | grep "$1" | sed -e "s/dll.*/dll/"';2,$d'`]) ;;
    dylib) AS_VAR_SET(ac_Lib,[`otool -L conftest$ac_exeext | grep "ac_lib_pattern\\.[[0-9A-Za-z.]]*dylib" | sed -e "s/^.*\/\(ac_lib_pattern\.[[0-9A-Za-z.]]*dylib\).*$/\1/"';2,$d'`]) ;;
    *) AS_VAR_SET(ac_Lib,[`$ac_cv_path_LDD conftest$ac_exeext | grep "ac_lib_pattern\\.$LIBEXT" | sed -e "s/^.*\(ac_lib_pattern\.$LIBEXT[[^	 ]]*\).*$/\1/"';2,$d'`]) ;;
  esac])
  LIBS=$ac_check_soname_save_LIBS])dnl
AS_IF([test "x]AS_VAR_GET(ac_Lib)[" = "x"],
      [AC_MSG_RESULT([not found])
       $4],
      [AC_MSG_RESULT(AS_VAR_GET(ac_Lib))
       AC_DEFINE_UNQUOTED(AS_TR_CPP(SONAME_LIB$1),["]AS_VAR_GET(ac_Lib)["],
                          [Define to the soname of the lib$1 library.])
       $3])dnl
m4_popdef([ac_lib_pattern])dnl
AS_VAR_POPDEF([ac_Lib])])

dnl **** Link C code with an assembly file ****
dnl
dnl Usage: WINE_TRY_ASM_LINK(asm-code,includes,function,[action-if-found,[action-if-not-found]])
dnl
AC_DEFUN([WINE_TRY_ASM_LINK],
[AC_LINK_IFELSE(AC_LANG_PROGRAM([[$2]],[[asm($1); $3]]),[$4],[$5])])

dnl **** Check if we can link an empty program with special CFLAGS ****
dnl
dnl Usage: WINE_TRY_CFLAGS(flags,[action-if-yes,[action-if-no]])
dnl
dnl The default action-if-yes is to append the flags to EXTRACFLAGS.
dnl
AC_DEFUN([WINE_TRY_CFLAGS],
[AS_VAR_PUSHDEF([ac_var], ac_cv_cflags_[[$1]])dnl
AC_CACHE_CHECK([whether the compiler supports $1], ac_var,
[ac_wine_try_cflags_saved=$CFLAGS
CFLAGS="$CFLAGS $1"
AC_LINK_IFELSE(AC_LANG_SOURCE([[int main(int argc, char **argv) { return 0; }]]),
               [AS_VAR_SET(ac_var,yes)], [AS_VAR_SET(ac_var,no)])
CFLAGS=$ac_wine_try_cflags_saved])
AS_IF([test AS_VAR_GET(ac_var) = yes],
      [m4_default([$2], [EXTRACFLAGS="$EXTRACFLAGS $1"])], [$3])dnl
AS_VAR_POPDEF([ac_var])])

dnl **** Check if we can link an empty shared lib (no main) with special CFLAGS ****
dnl
dnl Usage: WINE_TRY_SHLIB_FLAGS(flags,[action-if-yes,[action-if-no]])
dnl
AC_DEFUN([WINE_TRY_SHLIB_FLAGS],
[ac_wine_try_cflags_saved=$CFLAGS
CFLAGS="$CFLAGS $1"
AC_LINK_IFELSE([void myfunc() {}],[$2],[$3])
CFLAGS=$ac_wine_try_cflags_saved])

dnl **** Check whether we need to define a symbol on the compiler command line ****
dnl
dnl Usage: WINE_CHECK_DEFINE(name),[action-if-yes,[action-if-no]])
dnl
AC_DEFUN([WINE_CHECK_DEFINE],
[AS_VAR_PUSHDEF([ac_var],[ac_cv_cpp_def_$1])dnl
AC_CACHE_CHECK([whether we need to define $1],ac_var,
    AC_EGREP_CPP(yes,[#ifndef $1
yes
#endif],
    [AS_VAR_SET(ac_var,yes)],[AS_VAR_SET(ac_var,no)]))
AS_IF([test AS_VAR_GET(ac_var) = yes],
      [CFLAGS="$CFLAGS -D$1"
  LINTFLAGS="$LINTFLAGS -D$1"])dnl
AS_VAR_POPDEF([ac_var])])

dnl **** Check for functions with some extra libraries ****
dnl
dnl Usage: WINE_CHECK_LIB_FUNCS(funcs,libs,[action-if-found,[action-if-not-found]])
dnl
AC_DEFUN([WINE_CHECK_LIB_FUNCS],
[ac_wine_check_funcs_save_LIBS="$LIBS"
LIBS="$LIBS $2"
AC_CHECK_FUNCS([$1],[$3],[$4])
LIBS="$ac_wine_check_funcs_save_LIBS"])

dnl **** Check for a mingw program, trying the various mingw prefixes ****
dnl
dnl Usage: WINE_CHECK_MINGW_PROG(variable,prog,[value-if-not-found],[path])
dnl
AC_DEFUN([WINE_CHECK_MINGW_PROG],
[case "$host_cpu" in
  i[[3456789]]86*)
    ac_prefix_list="m4_foreach([ac_wine_prefix],[pc-mingw32, mingw32msvc, mingw32],
                        m4_foreach([ac_wine_cpu],[i686,i586,i486,i386],[ac_wine_cpu-ac_wine_prefix-$2 ]))" ;;
  x86_64)
    ac_prefix_list="m4_foreach([ac_wine_prefix],[pc-mingw32,w64-mingw32],[x86_64-ac_wine_prefix-$2 ])" ;;
  *)
    ac_prefix_list="" ;;
esac
AC_CHECK_PROGS([$1],[$ac_prefix_list],[$3],[$4])])


dnl **** Define helper functions for creating config.status files ****
dnl
dnl Usage: AC_REQUIRE([WINE_CONFIG_HELPERS])
dnl
AC_DEFUN([WINE_CONFIG_HELPERS],
[wine_fn_append_file ()
{
    AS_VAR_APPEND($[1]," \\$as_nl	$[2]")
}

wine_fn_append_rule ()
{
    AS_VAR_APPEND($[1],"$as_nl$[2]")
}

wine_fn_config_makefile ()
{
    ac_dir=$[1]
    ac_deps=$[2]
    wine_fn_append_file ALL_DIRS $ac_dir
    wine_fn_append_rule ALL_MAKEFILE_DEPENDS \
"$ac_dir/__clean__ $ac_dir/__install__ $ac_dir/__install-dev__ $ac_dir/__install-lib__ $ac_dir/__uninstall__ $ac_dir: $ac_dir/Makefile
$ac_dir/Makefile $ac_dir/__depend__: $ac_dir/Makefile.in config.status $ac_deps
	@./config.status --file $ac_dir/Makefile && cd $ac_dir && \$(MAKE) depend"
}

wine_fn_config_lib ()
{
    ac_name=$[1]
    wine_fn_append_file ALL_STATIC_LIBS dlls/$ac_name/lib$ac_name.a
    wine_fn_append_rule ALL_MAKEFILE_DEPENDS \
"dlls/$ac_name/__install__ dlls/$ac_name/__install-dev__: dlls/$ac_name
dlls/$ac_name dlls/$ac_name/lib$ac_name.cross.a: tools/widl tools/winebuild tools/winegcc include
dlls/$ac_name/lib$ac_name.cross.a: dlls/$ac_name/Makefile dummy
	@cd dlls/$ac_name && \$(MAKE) lib$ac_name.cross.a"
}

wine_fn_config_dll ()
{
    ac_dir=$[1]
    ac_implib=$[2]
    ac_implibsrc=$[3]
    ac_file="dlls/$ac_dir/lib$ac_implib"
    ac_deps="tools/widl tools/winebuild tools/winegcc include"

    wine_fn_append_rule ALL_MAKEFILE_DEPENDS \
"dlls/$ac_dir dlls/$ac_dir/__install__ dlls/$ac_dir/__install-lib__ dlls/$ac_dir/__install-dev__: __builddeps__"

    if test -n "$ac_implibsrc"
    then
        wine_fn_append_rule ALL_MAKEFILE_DEPENDS \
"$ac_file.$IMPLIBEXT $ac_file.$STATIC_IMPLIBEXT $ac_file.cross.a: $ac_deps
$ac_file.def: dlls/$ac_dir/$ac_dir.spec dlls/$ac_dir/Makefile
	@cd dlls/$ac_dir && \$(MAKE) \`basename \$[@]\`
$ac_file.$STATIC_IMPLIBEXT $ac_file.cross.a: dlls/$ac_dir/Makefile dummy
	@cd dlls/$ac_dir && \$(MAKE) \`basename \$[@]\`"
    elif test -n "$ac_implib"
    then
        wine_fn_append_rule ALL_MAKEFILE_DEPENDS \
"$ac_file.$IMPLIBEXT $ac_file.cross.a: $ac_deps
$ac_file.$IMPLIBEXT $ac_file.cross.a: dlls/$ac_dir/$ac_dir.spec dlls/$ac_dir/Makefile
	@cd dlls/$ac_dir && \$(MAKE) \`basename \$[@]\`"

        if test "$ac_dir" != "$ac_implib"
        then
            wine_fn_append_rule ALL_MAKEFILE_DEPENDS \
"dlls/lib$ac_implib.$IMPLIBEXT: $ac_file.$IMPLIBEXT
	\$(RM) \$[@] && \$(LN_S) $ac_dir/lib$ac_implib.$IMPLIBEXT \$[@]
dlls/lib$ac_implib.cross.a: $ac_file.cross.a
	\$(RM) \$[@] && \$(LN_S) $ac_dir/lib$ac_implib.cross.a \$[@]
clean::
	\$(RM) dlls/lib$ac_implib.$IMPLIBEXT"
        fi
    fi
}

wine_fn_config_program ()
{
    ac_dir=$[1]
    wine_fn_append_rule ALL_MAKEFILE_DEPENDS \
"programs/$ac_dir programs/$ac_dir/__install__ programs/$ac_dir/__install-lib__: __builddeps__"
}

wine_fn_config_test ()
{
    ac_dir=$[1]
    ac_name=$[2]
    wine_fn_append_file ALL_TEST_BINARIES $ac_name.exe
    wine_fn_append_rule ALL_WINETEST_DEPENDS \
"$ac_name.exe: \$(TOPOBJDIR)/$ac_dir/$ac_name.exe$DLLEXT
	cp \$(TOPOBJDIR)/$ac_dir/$ac_name.exe$DLLEXT \$[@] && \$(STRIP) \$[@]
$ac_name.rc:
	echo \"$ac_name.exe TESTRES \\\"$ac_name.exe\\\"\" >\$[@] || (\$(RM) \$[@] && false)
$ac_name.res: $ac_name.rc $ac_name.exe"
    wine_fn_append_rule ALL_MAKEFILE_DEPENDS "$ac_dir: __builddeps__"
    wine_fn_append_rule ALL_MAKEFILE_DEPENDS "$ac_dir/__crosstest__: __buildcrossdeps__ $ac_dir/Makefile"
}])

dnl **** Define helper function to append a file to a makefile file list ****
dnl
dnl Usage: WINE_APPEND_FILE(var,file)
dnl
AC_DEFUN([WINE_APPEND_FILE],[AC_REQUIRE([WINE_CONFIG_HELPERS])wine_fn_append_file $1 "$2"])

dnl **** Define helper function to append a rule to a makefile command list ****
dnl
dnl Usage: WINE_APPEND_RULE(var,rule)
dnl
AC_DEFUN([WINE_APPEND_RULE],[AC_REQUIRE([WINE_CONFIG_HELPERS])wine_fn_append_rule $1 "$2"])

dnl **** Create nonexistent directories from config.status ****
dnl
dnl Usage: WINE_CONFIG_EXTRA_DIR(dirname)
dnl
AC_DEFUN([WINE_CONFIG_EXTRA_DIR],
[AC_CONFIG_COMMANDS([$1],[test -d "$1" || { AC_MSG_NOTICE([creating $1]); AS_MKDIR_P("$1"); }])])

dnl **** Create symlinks from config.status ****
dnl
dnl Usage: WINE_CONFIG_SYMLINK(name,target)
dnl
AC_DEFUN([WINE_CONFIG_SYMLINK],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
AC_CONFIG_LINKS([$1:]m4_default([$2],[$1]))dnl
m4_if([$2],,[test "$srcdir" = "." || ])WINE_APPEND_FILE(ALL_SYMLINKS,[$1])])

dnl **** Create a make rules file from config.status ****
dnl
dnl Usage: WINE_CONFIG_MAKERULES(file,var,deps)
dnl
AC_DEFUN([WINE_CONFIG_MAKERULES],
[WINE_APPEND_FILE(ALL_MAKERULES,[$1])
WINE_APPEND_RULE(ALL_MAKEFILE_DEPENDS,[$1: m4_ifval([$3],[$1.in $3],[$1.in]) config.status])
$2=$1
AC_SUBST_FILE([$2])dnl
AC_CONFIG_FILES([$1])])

dnl **** Create a makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_MAKEFILE(file,deps,var,enable)
dnl
AC_DEFUN([WINE_CONFIG_MAKEFILE],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
m4_pushdef([ac_dir],m4_bpatsubst([$1],[^\(\(.*\)/\)?Makefile$],[\2]))dnl
m4_pushdef([ac_name],m4_bpatsubst(ac_dir,[.*/\(.*\)$],[\1]))dnl
m4_if(ac_dir,,WINE_APPEND_RULE(ALL_MAKEFILE_DEPENDS,[$1: $1.in $2 config.status])
AC_CONFIG_FILES([$1]),
[wine_fn_config_makefile ac_dir m4_if(ac_dir,tools,[$2],["$2 \$(MAKEDEP)"])
AS_VAR_PUSHDEF([ac_enable],m4_default([$4],[enable_]ac_name))dnl
m4_ifval([$3],[test "x$ac_enable" != xno]m4_foreach([ac_var],[$3],[ && WINE_APPEND_FILE(ac_var,ac_dir)]))
AS_VAR_POPDEF([ac_enable])])dnl
m4_popdef([ac_dir])dnl
m4_popdef([ac_name])])

dnl **** Create a dll makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_DLL(name,enable,implib,implibsrc)
dnl
AC_DEFUN([WINE_CONFIG_DLL],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
m4_pushdef([ac_implib],m4_ifval([$3],[dlls/$1/lib$3.$IMPLIBEXT]))dnl
m4_ifval(ac_implib,[m4_ifval([$2],[test "x$[$2]" != xno && ])WINE_APPEND_FILE(ALL_IMPORT_LIBS,ac_implib)dnl
m4_if([$1],[$3],,[ && WINE_APPEND_FILE(ALL_IMPORT_LIBS,[dlls/lib$3.$IMPLIBEXT])])dnl
m4_ifval([$4],[ && WINE_APPEND_FILE(ALL_IMPORT_LIBS,[dlls/$1/lib$3.$STATIC_IMPLIBEXT])])
])wine_fn_config_dll [$1] [$3] m4_ifval([$4],["$4"])
WINE_CONFIG_MAKEFILE([dlls/$1/Makefile],[dlls/Makedll.rules],[ALL_DLL_DIRS],[$2])dnl
m4_popdef([ac_implib])])

dnl **** Create a program makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_PROGRAM(name,var,enable)
dnl
AC_DEFUN([WINE_CONFIG_PROGRAM],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
wine_fn_config_program [$1]
WINE_CONFIG_MAKEFILE([programs/$1/Makefile],[programs/Makeprog.rules],[$2],[$3])])

dnl **** Create a test makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_TEST(dir)
dnl
AC_DEFUN([WINE_CONFIG_TEST],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
m4_pushdef([ac_suffix],m4_if(m4_substr([$1],0,9),[programs/],[.exe_test],[_test]))dnl
m4_pushdef([ac_name],[m4_bpatsubst([$1],[.*/\(.*\)/tests$],[\1])])dnl
wine_fn_config_test $1 ac_name[]ac_suffix
WINE_CONFIG_MAKEFILE([$1/Makefile],[Maketest.rules],[ALL_TEST_DIRS],[enable_tests])dnl
m4_popdef([ac_suffix])dnl
m4_popdef([ac_name])])

dnl **** Create a static lib makefile from config.status ****
dnl
dnl Usage: WINE_CONFIG_LIB(name)
dnl
AC_DEFUN([WINE_CONFIG_LIB],[AC_REQUIRE([WINE_CONFIG_HELPERS])dnl
wine_fn_config_lib $1
WINE_CONFIG_MAKEFILE([dlls/$1/Makefile],[dlls/Makeimplib.rules],[ALL_STATICLIB_DIRS])])

dnl **** Add a message to the list displayed at the end ****
dnl
dnl Usage: WINE_NOTICE(notice)
dnl Usage: WINE_NOTICE_WITH(with_flag, test, notice)
dnl Usage: WINE_WARNING(warning)
dnl Usage: WINE_WARNING_WITH(with_flag, test, warning)
dnl Usage: WINE_PRINT_MESSAGES
dnl
AC_DEFUN([WINE_NOTICE],[AS_VAR_APPEND([wine_notices],["|$1"])])
AC_DEFUN([WINE_WARNING],[AS_VAR_APPEND([wine_warnings],["|$1"])])

AC_DEFUN([WINE_NOTICE_WITH],[AS_IF([$2],[case "x$with_$1" in
  x)   WINE_NOTICE([$3]) ;;
  xno) ;;
  *)   AC_MSG_ERROR([$3
This is an error since --with-$1 was requested.]) ;;
esac])])

AC_DEFUN([WINE_WARNING_WITH],[AS_IF([$2],[case "x$with_$1" in
  x)   WINE_WARNING([$3]) ;;
  xno) ;;
  *)   AC_MSG_ERROR([$3
This is an error since --with-$1 was requested.]) ;;
esac])])

AC_DEFUN([WINE_ERROR_WITH],[AS_IF([$2],[case "x$with_$1" in
  xno) ;;
  *)   AC_MSG_ERROR([$3
Use the --without-$1 option if you really want this.]) ;;
esac])])

AC_DEFUN([WINE_PRINT_MESSAGES],[ac_save_IFS="$IFS"
if test "x$wine_notices != "x; then
    echo >&AS_MESSAGE_FD
    IFS="|"
    for msg in $wine_notices; do
        IFS="$ac_save_IFS"
        if test -n "$msg"; then
            AC_MSG_NOTICE([$msg])
        fi
    done
fi
IFS="|"
for msg in $wine_warnings; do
    IFS="$ac_save_IFS"
    if test -n "$msg"; then
        echo >&2
        AC_MSG_WARN([$msg])
    fi
done
IFS="$ac_save_IFS"])

dnl Local Variables:
dnl compile-command: "autoreconf --warnings=all"
dnl End:
