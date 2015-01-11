#!/usr/bin/env sh 
set -e

# Source directory
#
srcdir=`dirname $0`
srcdir=`cd $srcdir; pwd`
dstdir=`pwd`

bindir=$srcdir/../..
npm=$srcdir/../../node_modules/.bin

touch "with space.pdf"
rm -f "spaced with space.pdf"
$bindir/index.js -g '*' 'spaced *' $srcdir/*.pdf > /dev/null && tree > dest.txt
$npm/diff-files $srcdir/dest.txt $srcdir/ref.txt -m "With files that have spaces in them"


