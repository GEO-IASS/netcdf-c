#!/bin/sh

if test "x$1" = x ; then rm -fr parse.log; sh -x $0 log >>parse.log ; exit 0; fi

if test "x$srcdir" = "x" ; then srcdir=`dirname $0`; fi; export srcdir

. ${srcdir}/test_common.sh

rm -f ./parse.log
sh -x ${srcdir}/test_parse.sh >& ./parse.log
echo '----------------'
cat ./parse.log
echo '----------------'
exit 0
