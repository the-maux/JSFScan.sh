#!/bin/bash

# list of installed soft: INTERLACE / SECRETFINDER / LINKFINDER / GAU / SUBJS / HTTPX / HAKRAWLER

cd ./tools

git clone https://github.com/codingo/Interlace.git
git clone https://github.com/m4ll0k/SecretFinder.git
git clone https://github.com/dark-warlord14/LinkFinder

#INSTALL INTERLACE
echo -e "\n-----------------------INSTALLING PYTHON LIBS ------------------------"
cat ./Interlace/requirements.txt > requirements.txt
cat ./SecretFinder/requirements.txt >> requirements.txt
cat ./LinkFinder/requirements.txt >> requirements.txt
pip3 install -r requirements.txt || exit
pwd
ls
cd Interlace && python3 ./Interlace/setup.py install || exit && cd -
pwd
ls
cd LinkFinder && python3 ./LinkFinder/setup.py install || exit && cd -

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

