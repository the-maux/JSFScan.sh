#!/bin/bash

# Todo check if the output directory already exist, caused it failed if yes
# Todo make a proctection when no .js file are found, to avoir the infinite loop in C.I
# Todo detect if targets in target.txt have the https://, if not: add it

echo -e "\e[36m _______ ______ _______ ______                          _     \e[0m"
echo -e "\e[36m(_______/ _____(_______/ _____)                        | |    \e[0m"
echo -e "\e[36m     _ ( (____  _____ ( (____   ____ _____ ____     ___| |__  \e[0m"
echo -e "\e[36m _  | | \____ \|  ___) \____ \ / ___(____ |  _ \   /___|  _ \ \e[0m"
echo -e "\e[36m| |_| | _____) | |     _____) ( (___/ ___ | | | |_|___ | | | |\e[0m"
echo -e "\e[36m \___/ (______/|_|    (______/ \____\_____|_| |_(_(___/|_| |_|\e[0m\n"

############################################  RECON PART   #############################################################

combine_assetfinder_gau_subjs() {  # mixing assetfinder + gau + subjs together
  cat target.txt | sed 's$https://$$' > urls_no_http.txt
  cat urls_no_http.txt | assetfinder | sort -u > assetfinder.txt
  echo -e "(DEBUG) assetfinder found: $(cat assetfinder.txt | wc -l) file(s)"
  cat assetfinder.txt |  gau -subs -b png,jpg,jpeg,html,txt,JPG | sort -u > gau.txt
  echo -e "(DEBUG) assetfinder + gau found: $(cat gau.txt | wc -l) file(s)"
  cat gau.txt | subjs | grep -v '?v=' | sort -u > subjs.txt
  echo -e "(DEBUG) assetfinder + gau + subjs found: $(cat subjs.txt | wc -l) file(s)"
}

#Gather JSFilesUrls with gau / subjs / assetfinder / gospider / hakrawler
use_recontools_individualy() {
  # TOKNOW: assetfinder is not working good with "https://"
  cat target.txt | gau | grep -iE "\.js$" | sort -u > gau_solo_urls.txt
  echo -e "(DEBUG) gau individually found: $(cat gau_solo_urls.txt | wc -l) file(s)"
  cat gau_solo_urls.txt | subjs > subjs_url.txt
  echo -e "(DEBUG) subjs individually found: $(cat subjs_url.txt | wc -l) file(s)"
  cat target.txt | sed 's$https://$$' | assetfinder -subs-only | httpx -timeout 3 -threads 300 --follow-redirects -silent | xargs -I% -P10 sh -c 'hakrawler -plain -linkfinder -depth 5 -url %' | awk '{print $3}' | grep -E "\.js(?:onp?)?$" | sort -u > assetfinder_urls.txt
  echo -e "(DEBUG) assetfinder individually found: $(cat assetfinder_urls.txt | wc -l) file(s)"
  # TOKNOW: gospider is not working good without the "https://"
  gospider -a -w -r -S target.txt -d 3 | grep -Eo "(http|https)://[^/\"].*\.js+" | sed "s#\] \- #\n#g" > gospider_url.txt
  echo -e "(DEBUG) gospider individually found: $(cat gospider_url.txt | wc -l) file(s)"
  cat target.txt | hakrawler -js -depth 2 -scope subs -plain > hakrawler_urls.txt
  echo -e "(DEBUG) hakrawler individually found: $(cat hakrawler_urls.txt | wc -l) file(s)"
}

recon_js_url() {
  use_recontools_individualy # result in gau_solo_urls.txt subjs_url.txt hakrawler_urls.txt gospider_url.txt
  cat gau_solo_urls.txt >> all_urls.txt;
  cat gau_solo_urls.txt >> all_urls.txt;
  cat subjs_url.txt >> all_urls.txt;
  cat hakrawler_urls.txt >> all_urls.txt;
  cat gospider_url.txt >> all_urls.txt;
  cat subjs.txt >> all_urls.txt
  echo "(INFO) Removing dead links with httpx & filtering duplicate url"
  cat all_urls.txt | httpx -follow-redirects -status-code -silent | grep "[200]" | cut -d ' ' -f1 | sort -u | grep -v '?v=' > urls_alive.txt
  cat urls_alive.txt | grep -v "jquery" > urls.txt  # filtering classic lib with no impact
  number_of_file_found=$(cat urls.txt | wc -l)
  echo "(INFO) After filtering duplicate/offline/boring js files, we found: $((number_of_file_found)) files to analyse"
  cat urls.txt
  if [ $number_of_file_found = "0" ]
  then
      echo "(ERROR) No JS file found during recon, Exiting..."
      exit 1
  fi
}

#Gather Endpoints From JsFiles
endpoint_js() {
  # TOKNOW: linkfinder doesnt work if https is present
  interlace -tL urls_no_http.txt -threads 5 -c "python3 ./tools/LinkFinder/linkfinder.py -d -i _target_ -o cli >> all_endpoints.txt" --silent --no-bar
  number_of_endpoint_found=$(cat all_endpoints.txt | wc -l)
  if [ $number_of_endpoint_found = "0" ]
  then
      echo "(WARNING) No endpoint found"
  fi
  cat all_endpoints.txt | sort -u > endpoints.txt
  echo "(INFO) Number of endpoint found: $(cat endpoints.txt | wc -l)"
}

#Collect Js Files For Maually Search
getjsbeautify() {
  mkdir -p /root/jsfiles
  python3 ./tools/jsbeautify.py
  echo "(INFO) Getjsbeautify downloaded: $(ls -l /root/jsfiles/ | wc -l) files"
}

#Gather JSFilesWordlist
wordlist_js() {
  cat urls.txt | python3 ./tools/getjswords.py >> temp_jswordlist.txt
  cat temp_jswordlist.txt | sort -u >> jswordlist.txt
  echo "(INFO) getjswords found $(cat jswordlist.txt | wc -l) JSWord(s)"
  rm temp_jswordlist.txt
}

############################################  ANALYSE SECTION ##########################################################
#Gather Variables from JSFiles For Xss
var_js() {
  cat urls.txt | while read url; do bash ./tools/jsvar.sh $url | tee -a js_var.txt; done
  echo "(INFO) Var with possible xss :$(cat js_var.txt | wc -l)"
}

#Find DomXSS
domxss_js() {
  interlace -tL urls.txt -threads 5 -c "bash ./tools/findomxss.sh _target_" --silent --no-bar
}

#Gather Secrets From Js Files
secret_js() {
  interlace -tL urls.txt -threads 5 -c "python3 ./tools/SecretFinder/SecretFinder.py -i _target_ -o cli >> jslinksecret.txt" --silent --no-bar
  echo -n "(INFO) Number of secrets found: " && cat jslinksecret.txt | wc -l
}

############################################  REPORT SECTION ###########################################################

#Save in Output Folder
output() {
  dir=$OUTPUT_DIR
  mkdir -p $dir
  mv -vf endpoints.txt all_urls.txt jslinksecret.txt urls.txt jswordlist.txt js_var.txt domxss_scan.txt report.html $dir/
  mv -v jsfiles/ $dir/
  tar -cvf archive.tar $dir/
}

send_to_issue() {
  token=$GITHUB_TOKEN
  repo=the-maux/JSFScan.sh

  upload_url=$(curl -s -H "Authorization: token $token"  \
     -d '{"tag_name": "test", "name":"release-0.0.1","body":"this is the result of the scan"}'  \
     "https://api.github.com/repos/$repo/releases" | jq -r '.upload_url')

  upload_url="${upload_url%\{*}"

  echo "uploading asset to release to url : $upload_url"

  curl -s -H "Authorization: token $token"  \
        -H "Content-Type: application/zip" \
        --data-binary @archive.tar  \
        "$upload_url?name=archive.tar&label=JSHUNT"
}

export PYTHONWARNINGS="ignore:Unverified HTTPS request"

recon() {  # Try to gain the maximum of uniq JS file from the target
  echo "Searching JSFiles on target(s):" && cat target.txt
  echo -e "\e[36m[+] Searching JsFiles-links mixing gau & subjs & assetfinder \e[0m"
  combine_assetfinder_gau_subjs  # result in subjs.txt
  echo -e "\e[36m[+] Searching JsFiles-links individualy gau & subjs & hakrawler & assetfind & gospider \e[0m"
  recon_js_url
  echo -e "\e[36m[+] Started gathering Endpoints\e[0m"
  endpoint_js
  echo -e "\e[36m[+] Started to Gather JSFiles locally for Manual Testing\e[0m"
  getjsbeautify
}


analyse() {
  echo -e "\e[36m[+] Started Gathering Words From JsFiles-links For Wordlist.\e[0m"
  wordlist_js
  echo -e "\e[36m[+] Started Finding Varibles in JSFiles For Possible XSS\e[0m"
  var_js
  echo -e "\e[36m[+] Scanning JSFiles For Possible DomXSS\e[0m"
  domxss_js
  echo -e "\e[36m[+]  Started Finding Secrets in JSFiles\e[0m"
  secret_js
}

report() {
  echo -e "\e[36m[+]  Generating Html Report!\e[0m"
  bash report.sh
  echo -e "\e[36m[+]  Generating output directory!\e[0m"
  output
  echo -e "\e[36m[+]  Sending report to github project  !\e[0m"
  send_to_issue
}

recon
#analyse
#report
