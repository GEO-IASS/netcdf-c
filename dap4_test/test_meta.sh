#!/bin/sh

if test x"$1" = x ; then rm -fr meta.log; sh -x $0 log >>meta.log; exit 0 ; fi

if test "x$srcdir" = "x"; then srcdir=`dirname $0`; fi; export srcdir

. ${srcdir}/test_common.sh

cd ${DMRTESTFILES}
F=`ls -1 *.dmr | sed -e 's/[.]dmr//g' | tr '\r\n' '  '`
cd $WD

CDL=
for f in ${F} ; do
STEM=`echo $f | cut -d. -f 1`
if test -a ${CDLTESTFILES}/${STEM}.cdl ; then
  CDL="${CDL} ${STEM}"
else
  echo "Not found: ${CDLTESTFILES}/${STEM}.cdl"
fi
done

if test "x${RESET}" = x1 ; then rm -fr ${BASELINE}/*.d4m ; fi

for f in ${F} ; do
    echo "checking: $f"
    if ! ${VG} ./test_meta ${DMRTESTFILES}/${f}.dmr ./results/${f} ; then
        failure "./test_meta ${DMRTESTFILES}/${f}.dmr ./results/${f}"
    fi
    ../ncdump/ncdump -h ./results/${f} > ./results/${f}.d4m
    if test "x${TEST}" = x1 ; then
	if ! diff -wBb ${BASELINE}/${f}.d4m ./results/${f}.d4m ; then
	    failure "diff -wBb ${BASELINE}/${f}.ncdump ./results/${f}.d4m"
	fi
    elif test "x${RESET}" = x1 ; then
	echo "${f}:" 
	cp ./results/${f}.d4m ${BASELINE}/${f}.d4m
    fi
done

if test "x${CDLDIFF}" = x1 ; then
  for f in $CDL ; do
    echo "diff -wBb ${CDLTESTFILES}/${f}.cdl ./results/${f}.d4m"
    rm -f ./tmp
    cat ${CDLTESTFILES}/${f}.cdl \
    cat >./tmp
    echo diff -wBbu ./tmp ./results/${f}.d4m
    if ! diff -wBbu ./tmp ./results/${f}.d4m ; then
	failure "${f}" 
    fi
  done
fi

finish

