filename=$(echo $1 | awk -F/ '{print $(NF-0)}')
echo "jsbeautify ouput: $((filename))"
python3 ./tools/jsbeautify.py $1 $filename
mv "$filename" ./jsfiles/
