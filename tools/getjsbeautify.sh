filename=$(echo $1 | awk -F/ '{print $(NF-0)}')
echo "AAAAAAAAAAAAAAAA"
echo "jsbeautify ouput: $((filename))"
echo "BBBBBBBBBBBBBBBB"
python3 ./tools/jsbeautify.py $1 $filename
echo "CCCCCCCCCCCCCCCC"
mv "$filename" ./jsfiles/
