FROM golang:latest
MAINTAINER bolli95 "maxlukasboll@gmail.com"

# install all depedencies
RUN apt -y update && apt -y install git wget python3 python3-pip

RUN mkdir -p /root/tools

# copy all files to the container
COPY . /root
WORKDIR /root/tools
# install all tools

RUN git clone https://github.com/codingo/Interlace.git
RUN git clone https://github.com/dark-warlord14/LinkFinder
RUN git clone https://github.com/m4ll0k/SecretFinder.git

RUN cat ./Interlace/requirements.txt > requirements.txt
RUN cat ./SecretFinder/requirements.txt >> requirements.txt
RUN cat ./LinkFinder/requirements.txt >> requirements.txt
RUN pip3 install -r requirements.txt
RUN cd Interlace && python3 ./setup.py install
RUN cd LinkFinder && python3 ./setup.py install

RUN go get github.com/tomnomnom/waybackurls
RUN GO111MODULE=on go get -v github.com/lc/gau
RUN GO111MODULE=on go get -v github.com/lc/subjs
RUN GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
RUN GO111MODULE=on go get -v github.com/hakluke/hakrawler

RUN chmod +x /root/JSFScan.sh

WORKDIR /root

ENV HOME /root
ENV GOPATH=$HOME/go/bin
ENV PATH $PATH:$GOPATH

RUN echo "github.com\nstatic-assets.tesla.com" > target.txt

CMD ["/bin/bash", "./JSFScan.sh", "-l", "target.txt", "-all", "-r", "-o", "reportDirectory"]
#bash ./JSFScan.sh -l target.txt --all -r -o Pandao.ru