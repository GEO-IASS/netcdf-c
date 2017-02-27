#!/bin/sh

# Figure out various locations in the src/build tree.
# This is relatively fragile code and is essentially
# specific to netcdf-c. It does, however, have the virtue
# of isolating all this nonsense into one place.
# This will get somewhat simplified (I hope) when
# we move to a separate test_utilities directory

# This code is intended to provide constants
# for accessing various objects in the src/build
# tree(s) across multiple ways of building netcdf-c.
# Currently, the following build situations are supported.
# 1. Autoconf with make check: the src and build trees are the same
# 2. Autoconf with make distcheck: the src and build trees are distinct
# 3. Cmake on a *nix platform using e.g. gcc:
#    the src and build trees are distinct.
# 4. Cmake using Visual Studio (VS) compiler: obviously this implies Windows.
#    This only works if a number of *nix tools are available via Cygwin
#    or MinGW.
#
# The big difference between #3 and #4 is the handling of executables
# and the notion of a VS configuration type like Debug or Release.
# When using VS, executables are placed in a subdirectory of the build
# directory. That subdirectory is named by the configuration type.
# Thus one finds ncdump.exe in $top_builddir/ncdump/Debug instead of 
# $top_builddir/ncdump.
# 
# An additional issue is the extension of an executable: .exe vs nothing.
# This code attempts to figure out which is used.

# The goal, then, of this common code is to set up some useful
#constants for use in test shell scripts.
# 1. srcdir - absolute path to the source dir (e.g. ${top_srcdir}/ncgen)
# 2. top_srcdir - absolute path to the root of the source
# 3. top_builddir - absolute path to the root of the build directory;
#                   may be same as top_srcdir (e.g. #1).
# 4. builddir - absolute path of th the directory into which generated
#               stuff (.nc, .cdl, etc) is stored.
# 5. execdir - absolute path of the directory into which executables are
#              placed. For all but the VS case, execdir == builddir.
# 
# The following are defined to support inter-directory references.
# 6. NCDUMP - absolute path to the ncdump.exe executable
# 7. NCCOPY - absolute path to the nccopy.exe executable
# 8. NCGEN - absolute path to ncgen.exe
# 9. NCGEN3 - absolute path to ncgen3.exe

# Allow global set -x mechanism
if test "x$SETX" = x1 ; then set -x ; fi

# Test for cmake related items
if test "x$CMAKE_CONFIG_TYPE" != x -o "x$USECMAKE" != x ; then
  ISCMAKE=1;
fi

# Figure out srcdir
if test "x$srcdir" = x; then
  top_srcdir="$TOPSRCDIR"
fi
top_srcdir=${srcdir}/..

builddir=`pwd`
top_builddir="$builddir/.."

# Compute execdir as well as a suffix to use for accessing
# executables. Note that the leading '/' is needed to avoid
# occurrences of ...//... in a path
if test "x$CMAKE_CONFIG_TYPE" != x ; then
  # Assume case #4: visual studio
  VS="/${CMAKE_CONFIG_TYPE}"
else
  VS=
fi
execdir="${builddir}$VS"

# pick off the last component as the relative name of this directory
thisdir=`basename $srcdir`

WD=`pwd`
# Absolutize paths of interest
cd $srcdir; srcdir=`pwd` ; cd $WD
cd $top_srcdir; top_srcdir=`pwd` ; cd $WD
cd $builddir; builddir=`pwd` ; cd $WD
cd $top_builddir; top_builddir=`pwd` ; cd $WD
cd $execdir; execdir=`pwd` ; cd $WD

# If we have cygpath, then try to normalize
tcc_os=`uname -o`
if test "x$tcc_os" = xCygwin ; then
  ISCYGWIN=1
fi

if test "x$ISCYGWIN" = x1; then
srcdir=`cygpath -mla $srcdir`
top_srcdir=`cygpath -mla $top_srcdir`
builddir=`cygpath -mla $builddir`
top_builddir=`cygpath -mla $top_builddir`
execdir=`cygpath -mla $execdir`
fi

# For sun os
export srcdir top_srcdir builddir top_builddir execdir

# Figure out executable extension
if test -e "${top_builddir}/ncdump${VS}/ncdump.exe" ; then
  ext=".exe"
else
  ext=""
fi

# We need to locate certain executables (and other things) 
# Find the relevant directory
NCDUMP="${top_builddir}/ncdump${VS}/ncdump${ext}"
NCCOPY="${top_builddir}/ncdump${VS}/nccopy${ext}"
NCGEN="valgrind --leak-check=full ${top_builddir}/ncgen${VS}/ncgen${ext}"
NCGEN3="${top_builddir}/ncgen3${VS}/ncgen3${ext}"

# Make sure we are in builddir (not execdir)
cd $builddir

# Temporary hacks (until we have a test_utils directory
ncgen3c0="${top_srcdir}/ncgen3/c0.cdl"
ncgenc0="${top_srcdir}/ncgen/c0.cdl"
ncgenc04="${top_srcdir}/ncgen/c0_4.cdl"

# Need to put netcdf.dll into the path if using cmake
if test "x$ISCMAKE" = x1 ; then
  NCLIBDIR="${top_builddir}/liblib${VS}"
  if test "x$ISCYGWIN" = x1; then
    NCLIBDIR=`cygpath -ua $NCLIBDIR`
  fi
  export PATH="${NCLIBDIR}:${PATH}"
fi
