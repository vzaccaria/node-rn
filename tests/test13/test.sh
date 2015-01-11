#!/usr/bin/env sh 
set -e

# Source directory
#
srcdir=`dirname $0`
srcdir=`cd $srcdir; pwd`
dstdir=`pwd`

bindir=$srcdir/../..
npm=$srcdir/../../node_modules/.bin

touch "$srcdir/tst/with space.pdf"
rm -f "$srcdir/spaced with space.pdf"
rm -f $srcdir/dest.txt

$bindir/index.js -g '*' "$srcdir/spaced *" $srcdir/tst/*.pdf > /dev/null && cd $srcdir && tree > $srcdir/dest.txt
$npm/diff-files $srcdir/dest.txt $srcdir/ref.txt -m "With files that have spaces in them"


