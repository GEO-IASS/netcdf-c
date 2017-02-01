#!/bin/sh

if test "x$srcdir" = "x" ; then srcdir=`dirname $0`; fi; export srcdir

sh -x ${srcdir}/test_parse.sh >& ./parse.log >& /dev/tty

exit 0
