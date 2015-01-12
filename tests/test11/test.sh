#!/usr/bin/env sh 
set -e

# Source directory
#
srcdir=`dirname $0`
srcdir=`cd $srcdir; pwd`
dstdir=`pwd`

bindir=$srcdir/../..
npm=$srcdir/../../node_modules/.bin
cd $srcdir
$bindir/index.js '*' '~/$D{YY}/s-$K-$000N' $srcdir/tst/*.pdf > $srcdir/dest.txt
$npm/diff-files $srcdir/dest.txt $srcdir/ref.txt -v -m "Should work with absolute dirs and indirect refs" 
