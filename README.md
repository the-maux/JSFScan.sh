#### Forked from https://github.com/KathanP19/JSFScan.sh

Script made for javascript recon automation in bugbounty;
It will scan a domain to find all interesting javascript files,
Once Js files collected, it send the results to your mail or in your local

## Usage:

`TOKNOW:` If you dont want to get the result by mail, just dont set the var USER_EMAIL

### Use throw Github Actions 
1. Fork the project
2. Replace the domain in the file target.txt, with your target
3. Add in the projects your secret [USER_EMAIL / USER_PASSWORD] (optional: CHAOS_TOKEN)
3. Push, and wait GithubActions to end

### Use throw Docker
1. docker build -t themaux/jsfscan:local .
2. Replace the domain in the file target.txt, with your target
3. docker run -e GITHUB_PASSWD="${{ secrets.GITHUB_TOKEN }}" \ 
        -e USER_EMAIL="${{ secrets.USER_EMAIL }}" \ 
        -e USER_PASSWORD="${{ secrets.USER_PASSWORD }}" \
        -e CHAOS_KEY="${{ secrets.CHAOS_TOKEN }}" \
        themaux/jsfscan:local

### Use by local 
`TOKNOW:` Need to have last version of go installed and python 3.7
1. bash ./install.sh
2. Replace the domain in the file target.txt, with your target
3. export in env the var [USER_EMAIL / USER_PASSWORD] (optional: CHAOS_TOKEN)
3. bash ./recon.sh

#### `Lists of tools`: 
- https://github.com/projectdiscovery/httpx/cmd/httpx
- https://github.com/projectdiscovery/subfinder/v2/cmd/subfinder
- https://github.com/projectdiscovery/chaos-client/cmd/chaos
- https://github.com/tomnomnom/waybackurls
- https://github.com/tomnomnom/assetfinder
- https://github.com/lc/gau
- https://github.com/lc/subjs
- https://github.com/codingo/Interlace.git
- https://github.com/dark-warlord14/LinkFinder
- https://github.com/m4ll0k/SecretFinder.git
- https://github.com/nsonaniya2010/SubDomainizer.git
- https://github.com/aboul3la/Sublist3r.git
- https://github.com/hakluke/hakrawler
- https://github.com/jaeles-project/gospider
- https://github.com/dwisiswant0/unew
- https://github.com/hiddengearz/jsubfinder
- BASH :heart:


#### TODO:
- Full chaos support
- Improve GithubActions report (build a workflow when job are more long than 6hours)
- Gif exemples
