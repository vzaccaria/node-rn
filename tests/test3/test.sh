#!/usr/bin/env sh 
set -e

# Source directory
#
srcdir=`dirname $0`
srcdir=`cd $srcdir; pwd`
dstdir=`pwd`

bindir=$srcdir/../..
npm=$srcdir/../../node_modules/.bin

$bindir/index.js -x '*.pdf' '$E/s-$K-$000N.pdf' $srcdir/*.pdf > $srcdir/dest.txt
$npm/diff-files $srcdir/dest.txt $srcdir/ref.txt -m "Should work by substituting extensions, using from=*"
