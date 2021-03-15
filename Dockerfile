# TOKNOW: Config is herited from image themaux/jsfscan:latest on docker.io to bypass long docker build
FROM themaux/jsfscan:latest

COPY . /opt/JSFScan.sh
WORKDIR /opt/JSFScan.sh

CMD ["/bin/bash", "./recon.sh"]
