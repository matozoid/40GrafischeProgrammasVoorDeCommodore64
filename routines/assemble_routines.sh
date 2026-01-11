#!/usr/bin/env bash

64tass routines.asm -o routines.prg --list=routines.list

EXPECTED_SHA256=1ce11e67187253f6f43c038f5718b6b79fca2bf09e5d61eaddd479a7abab311d

read ACTUAL_SHA256 _ < <(sha256sum routines.prg)

if [ $ACTUAL_SHA256 != $EXPECTED_SHA256 ]; then
    echo "SHA256 mismatch. Expected: $EXPECTED_SHA256, got: $ACTUAL_SHA256"
else
    echo "SHA256:            $ACTUAL_SHA256 OK"
fi
