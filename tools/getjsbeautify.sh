filename=$(echo $1 | awk -F/ '{print $(NF-0)}')
echo $filename
python3 ./tools/jsbeautify.py $1 $filename
ls -l ./jsfiles
mv $filename ./jsfiles/
