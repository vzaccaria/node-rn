#!/usr/bin/env sh 
set -e

# Source directory
#
srcdir=`dirname $0`
srcdir=`cd $srcdir; pwd`
dstdir=`pwd`

bindir=$srcdir/../..
npm=$srcdir/../../node_modules/.bin

$bindir/index.js '*' '*' $srcdir/*.pdf -t 'classify' > $srcdir/dest.txt
$npm/diff-files $srcdir/dest.txt $srcdir/ref.txt -m "Should work by applying final transform"
