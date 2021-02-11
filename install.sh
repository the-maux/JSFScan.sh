#!/bin/bash



#INSTALL INTERLACE
echo -e "\n-----------------------INSTALLING INTERLACE------------------------"
cd ./tools || exit
git clone https://github.com/codingo/Interlace.git
cd - || exit
pip3 install -r ./tools/Interlace/requirements.txt
cd ./tools/Interlace/ || exit
if ! test $(which sudo); then
	python3 setup.py install
else
	sudo python3 setup.py install
fi
cd - || exit
echo -e "\n-----------------------FINISHED INSTALLING INTERLACE------------------------"

#INSTALL SECRETFINDER
echo -e "\n-----------------------INSTALLING SECRETFINDER------------------------"
cd ./tools || exit
git clone https://github.com/m4ll0k/SecretFinder.git
cd - || exit
pip3 install -r ./tools/SecretFinder/requirements.txt
echo -e "\n-----------------------FINISHED INSTALLING SECRETFINDER------------------------"

#INSTALL LINKFINDER
echo -e "\n-----------------------INSTALLING LINKFINDER------------------------"
cd ./tools || exit
git clone https://github.com/dark-warlord14/LinkFinder
cd - || exit
pip3 install -r ./tools/LinkFinder/requirements.txt
cd ./tools/LinkFinder/ || exit
if ! test `which sudo`; then
	python3 setup.py install || exit
else
	sudo python3 setup.py install || exit
fi
cd - || exit
echo -e "\n-----------------------FINISHED INSTALLING LINKFINDER------------------------"

#INSTALL GAU
echo -e "\n-----------------------INSTALLING GAU------------------------"
go get github.com/tomnomnom/waybackurls || exit
GO111MODULE=on go get -v github.com/lc/gau || exit
echo -e "\n-----------------------FINISHED INSTALLING GAU------------------------"

#INSTALL SUBJS
echo -e "\n-----------------------INSTALLING SUBJS------------------------"
GO111MODULE=on go get -v github.com/lc/subjs || exit
echo -e "\n-----------------------FINISHED INSTALLING SUBJS------------------------"

#INSTALL HAKCHECKURL
echo -e "\n-----------------------INSTALLING HTTPX------------------------"
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx || exit
echo -e "\n-----------------------FINISHED INSTALLING HTTPX------------------------"

#INSTALL HAKRAwler
echo -e "\n-----------------------INSTALLING HAKRAWLER------------------------"
GO111MODULE=on go get -v github.com/hakluke/hakrawler || exit
echo -e "\n-----------------------FINISHED INSTALLING HAKRAWLER------------------------"

