#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

FIFACOIND=${BITCOIND:-$BINDIR/fifacoind}
FIFACOINCLI=${BITCOINCLI:-$BINDIR/fifacoin-cli}
FIFACOINTX=${BITCOINTX:-$BINDIR/fifacoin-tx}
FIFACOINQT=${BITCOINQT:-$BINDIR/qt/fifacoin-qt}

[ ! -x $FIFACOIND ] && echo "$FIFACOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
FFCVER=($($FIFACOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$FIFACOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $FIFACOIND $FIFACOINCLI $FIFACOINTX $FIFACOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${FFCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${FFCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
