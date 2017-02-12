#!/bin/sh

# Figure out various locations in the src/build tree.
# This is relatively fragile code and is essentially
# specific to netcdf-c. It does, however, have the virtue
# of isolating all this nonsense into one place.
# This will get somewhat simplified (I hope) when
# we move to a separate test_utilities directory

# The goal of this common code is to set up some
# useful constants.
# 1. srcdir - absolute path to the source dir (e.g. ${top_srcdir}/ncgen)
# 2. top_srcdir - absolute path to the root of the source
# 3. top_builddir - absolute path to the root of the build directory;
#                   may be same as top_srcdir in some cases, but for
#                   netcdf cmake builds and automake distcheck builds,
#                   it will differ.
# 4. builddir - the directory into which generated stuff (.nc, .cdl, etc)
#               is stored (absolute path)
# 5. execdir - the directory into which executables are placed (absolute path).
#              For autoconf builds execdir == builddir. For cmake builds,
#              the execdir is a subdir of builddir
# 
# The following are defined to support inter-directory references.
# 6. NCDUMP - absolute path to the ncdump.exe executable
# 7. NCCOPY - absolute path to the nccopy.exe executable
# 8. NCGEN - absolute path to ncgen.exe
# 9. NCGEN3 - absolute path to ncgen3.exe

# Allow global set -x mechanism
if test "x$SETX" = x1 ; then set -x ; fi

# Are we under cmake? This is complicated
# because for some reason under travis, CMAKE_CONFIG_TYPE
# is not defined
ISCMAKE=0
if test "x$CMAKE_CONFIG_TYPE" != x ; then
  ISCMAKE=1;
elif test "x$USECMAKE" != x ; then
  ISCMAKE=1;
fi

# Figure out srcdir
if test "x$srcdir" == x; then
  top_srcdir="$TOPSRCDIR"
fi
top_srcdir=${srcdir}/..

builddir=`pwd`
top_builddir="$builddir/.."
execdir="$builddir"
if test "x$ISCMAKE" != x ; then
  ls -l $buildir
  execdir="$builddir/$CMAKE_CONFIG_TYPE"
fi

# pick off the last component
thisdir=`basename $srcdir`

WD=`pwd`
# Absolutize paths of interest
cd $srcdir; srcdir=`pwd` ; cd $WD
cd $top_srcdir; top_srcdir=`pwd` ; cd $WD
cd $builddir; builddir=`pwd` ; cd $WD
cd $top_builddir; top_builddir=`pwd` ; cd $WD
cd $execdir; execdir=`pwd` ; cd $WD

# If we have cygpath, then try to normalize
if cygpath $srcdir ; then
srcdir=`cygpath -mla $srcdir`
top_srcdir=`cygpath -mla $top_srcdir`
builddir=`cygpath -mla $builddir`
top_builddir=`cygpath -mla $top_builddir`
execdir=`cygpath -mla $execdir`
fi

# For sun os
export srcdir top_srcdir builddir top_builddir execdir

# Figure out executable extension
ext="" # default
if test "x$ISCMAKE" = x1 ; then
  if test -a "${top_builddir}/ncdump/${CMAKE_CONFIG_TYPE}/ncdump.exe" ; then ext=".exe"; fi
else
  if test -a "${top_builddir}/ncdump/ncdump.exe" ; then ext=".exe"; fi
fi

# We need to locate certain executables (and other things) 
# Find the relevant directory
if test "x$ISCMAKE" = x1 ; then
  NCDUMP="${top_builddir}/ncdump/${CMAKE_CONFIG_TYPE}/ncdump${ext}"
  NCCOPY="${top_builddir}/ncdump/${CMAKE_CONFIG_TYPE}/nccopy${ext}"
  NCGEN="${top_builddir}/ncgen/${CMAKE_CONFIG_TYPE}/ncgen${ext}"
  NCGEN3="${top_builddir}/ncgen3/${CMAKE_CONFIG_TYPE}/ncgen3${ext}"
else # !ISCMAKE
  NCDUMP="${top_builddir}/ncdump/ncdump${ext}"
  NCCOPY="${top_builddir}/ncdump/nccopy${ext}"
  NCGEN="${top_builddir}/ncgen/ncgen${ext}"
  NCGEN3="${top_builddir}/ncgen3/ncgen3${ext}"
fi

# Make sure we are in builddir
cd $builddir

# Final step: verify that certain programs are available
ncavailable()
{
    nca_which=`which $1`
    if test "x${nca_which:0:1}" != "x/" ; then
      echo "$1: not available"
    fi
}

ncavailable cut
ncavailable cmp
ncavailable diff
ncavailable cp
ncavailable cat

# Temporary hacks (until we have a test_utils directory
if test "x$ISCMAKE" = x1 ; then
ncgen3c0="${top_builddir}/ncgen3/c0.cdl"
ncgenc0="${top_builddir}/ncgen/c0.cdl"
ncgenc04="${top_builddir}/ncgen/c0_4.cdl"
else
ncgen3c0="${top_srcdir}/ncgen3/c0.cdl"
ncgenc0="${top_srcdir}/ncgen/c0.cdl"
ncgenc04="${top_srcdir}/ncgen/c0_4.cdl"
fi
