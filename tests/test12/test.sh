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
mkdir -p "$srcdir/tst"

touch "$srcdir/tst/with space.pdf"
rm -f "$srcdir/tst/spaced with space.pdf"
rm -f $srcdir/dest.txt

$bindir/index.js -g '*' 'spaced *' $srcdir/tst/*.pdf > /dev/null && cd $srcdir && tree | sed 's/\\//g' > $srcdir/dest.txt
$npm/diff-files $srcdir/dest.txt $srcdir/ref.txt -v -m "With files that have spaces in them"


