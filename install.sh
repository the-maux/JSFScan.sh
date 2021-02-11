#!/bin/bash

# list of installed soft: INTERLACE / SECRETFINDER / LINKFINDER / GAU / SUBJS / HTTPX / HAKRAWLER

cd ./tools

git clone https://github.com/codingo/Interlace.git
git clone https://github.com/m4ll0k/SecretFinder.git
git clone https://github.com/dark-warlord14/LinkFinder

#INSTALL INTERLACE
echo -e "\n-----------------------INSTALLING INTERLACE------------------------"
pip3 install -r ./Interlace/requirements.txt || exit
sudo python3 Interlace/setup.py install || exit
echo -e "\n-----------------------INSTALLING SECRETFINDER------------------------"
pip3 install -r ./SecretFinder/requirements.txt || exit
echo -e "\n-----------------------INSTALLING LINKFINDER------------------------"
pip3 install -r ./tools/LinkFinder/requirements.txt || exit
sudo python3 ./LinkFinder/setup.py install || exit

#INSTALL GAU
echo -e "\n-----------------------INSTALLING GAU------------------------"
go get github.com/tomnomnom/waybackurls || exit
GO111MODULE=on go get -v github.com/lc/gau || exit
echo -e "\n-----------------------INSTALLING SUBJS------------------------"
GO111MODULE=on go get -v github.com/lc/subjs || exit
echo -e "\n-----------------------INSTALLING HTTPX------------------------"
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx || exit
echo -e "\n-----------------------INSTALLING HAKRAWLER------------------------"
GO111MODULE=on go get -v github.com/hakluke/hakrawler || exit

