#!/bin/bash

echo "START"
filename=$(echo $1 | awk -F/ '{print $(NF-0)}')
python3 ./tools/jsbeautify.py "$1" "$filename"
echo "START3"
mv -v "$filename" ./jsfiles/
echo "END"

