#!/usr/bin/env sh 
set -e

# Source directory
#
srcdir=`dirname $0`
srcdir=`cd $srcdir; pwd`
dstdir=`pwd`

bindir=$srcdir/../..
npm=$srcdir/../../node_modules/.bin

$srcdir/clean.sh

for f in $srcdir/test*
do
	# is it a directory?
	if [ -d "$f" ]; then
	    $f/test.sh
	fi
done
