echo "START"
filename=$(echo $1 | awk -F/ '{print $(NF-0)}')
echo "START1"
echo $1
echo "START21"
echo $filename
echo "START22"
echo "python3 ./tools/jsbeautify.py $1 $filename"
python3 ./tools/jsbeautify.py $1 $filename
echo "START3"
mv -v $filename ./jsfiles/
echo "END"

