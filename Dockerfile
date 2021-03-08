#FROM golang:latest
#MAINTAINER bolli95 "maxlukasboll@gmail.com"
#
## copy all files to the container
#RUN mkdir -p /root/tools
#
#WORKDIR /root/tools
#
## install binary depedencies
#RUN apt -y update && apt -y install git wget python3 python3-pip \
# && apt-get clean
#
## install python tools
#RUN git clone https://github.com/codingo/Interlace.git
#RUN git clone https://github.com/dark-warlord14/LinkFinder
#RUN git clone https://github.com/m4ll0k/SecretFinder.git
#RUN git clone https://github.com/nsonaniya2010/SubDomainizer.git
#RUN git clone https://github.com/aboul3la/Sublist3r.git
#
#RUN cat ./Interlace/requirements.txt > requirements.txt
#RUN cat ./SecretFinder/requirements.txt >> requirements.txt
#RUN cat ./LinkFinder/requirements.txt >> requirements.txt
#RUN cat ./Sublist3r/requirements.txt >> requirements.txt
#RUN cat ./SubDomainizer/requirements.txt | grep -v "requests" >> requirements.txt
#RUN echo "colorama" >> requirements.txt
#RUN pip3 install -r requirements.txt
#RUN cd Interlace && python3 ./setup.py install
#RUN cd LinkFinder && python3 ./setup.py install
#
## install go tools
#RUN go get github.com/tomnomnom/waybackurls
#RUN GO111MODULE=on go get -u github.com/tomnomnom/assetfinder
#RUN GO111MODULE=on go get -v github.com/hakluke/hakrawler
#RUN GO111MODULE=on go get -u github.com/jaeles-project/gospider
#RUN GO111MODULE=on go get -u github.com/dwisiswant0/unew
# # No need, cause 1 target: RUN GO111MODULE=on go get -u github.com/shenwei356/rush
#RUN GO111MODULE=on go get -u github.com/hiddengearz/jsubfinder
#RUN GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
#RUN GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
#RUN GO111MODULE=on go get -v github.com/projectdiscovery/chaos-client/cmd/chaos
#RUN GO111MODULE=on go get -v github.com/lc/gau
#RUN GO111MODULE=on go get -v github.com/lc/subjs
#RUN wget https://raw.githubusercontent.com/hiddengearz/jsubfinder/master/.jsf_signatures.yaml && mv .jsf_signatures.yaml ~/.jsf_signatures.yaml
#WORKDIR /root
#
#ENV HOME /root
#ENV GOPATH=$HOME/go/bin
#ENV PATH $PATH:$GOPATH
#ENV OUTPUT_DIR=/root/reportDirectory

# TOKNOW: Config is herited from image themaux/jsfscan on docker.io (i was tired to always wait the full build)
FROM themaux/jsfscan:latest

COPY . /root

CMD ["/bin/bash", "./recon.sh"]
