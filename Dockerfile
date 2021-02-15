#FROM golang:latest
#MAINTAINER bolli95 "maxlukasboll@gmail.com"
#
## copy all files to the container
#RUN mkdir -p /root/tools
#
#WORKDIR /root/tools
#
## install binary depedencies
#RUN apt -y update && apt -y install git wget python3 python3-pip
#
## install all python tools
#RUN git clone https://github.com/codingo/Interlace.git
#RUN git clone https://github.com/dark-warlord14/LinkFinder
#RUN git clone https://github.com/m4ll0k/SecretFinder.git
#
#RUN cat ./Interlace/requirements.txt > requirements.txt
#RUN cat ./SecretFinder/requirements.txt >> requirements.txt
#RUN cat ./LinkFinder/requirements.txt >> requirements.txt
#RUN pip3 install -r requirements.txt
#RUN cd Interlace && python3 ./setup.py install
#RUN cd LinkFinder && python3 ./setup.py install
#
## install all go tools
#RUN go get github.com/tomnomnom/waybackurls
#RUN GO111MODULE=on go get -v github.com/lc/gau
#RUN GO111MODULE=on go get -v github.com/lc/subjs
#RUN GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
#RUN GO111MODULE=on go get -v github.com/hakluke/hakrawler
#
#WORKDIR /root
#
#ENV HOME /root
#ENV GOPATH=$HOME/go/bin
#ENV PATH $PATH:$GOPATH
#ENV OUTPUT_DIR=/root/reportDirectory

#TOKNOW: Config is herited from image themaux/jsfscan on docker.io (i was tired to always wait the build)
FROM themaux/jsfscan:latest

COPY . /root

CMD ["/bin/bash", "./JSFScan.sh"]
