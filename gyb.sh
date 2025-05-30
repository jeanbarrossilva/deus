#!/bin/bash

find . -name '*.gyb' \
  | while read file; do $SRCROOT/gyb.py --line-directive '' -o "${file%.gyb}.swift" "$file"; done
