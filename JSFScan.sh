#!/bin/bash

# Todo check if the output directory already exist, caused it failed if yes

#LOgo
logo() {

  echo " _______ ______ _______ ______                          _     "
  echo "(_______/ _____(_______/ _____)                        | |    "
  echo "     _ ( (____  _____ ( (____   ____ _____ ____     ___| |__  "
  echo " _  | | \____ \|  ___) \____ \ / ___(____ |  _ \   /___|  _ \ "
  echo "| |_| | _____) | |     _____) ( (___/ ___ | | | |_|___ | | | |"
  echo " \___/ (______/|_|    (______/ \____\_____|_| |_(_(___/|_| |_|"
  echo "                                                              "

}
logo

#Gather JSFilesUrls
gather_js() {
  echo -e "\e[36m[\e[32m+\e[36m]\e[92m Started Gathering JsFiles-links with gau & subjs & hakrawler \e[0m\n"
  echo "Searching JSFiles on target(s):" && cat target.txt
  cat target.txt | gau | grep -iE "\.js$" | uniq | sort >> all_urls.txt
  cat target.txt | subjs >> all_urls.txt
  #cat target.txt | hakrawler -js -depth 2 -scope subs -plain >> all_urls.txt
  cat all_urls.txt | httpx -follow-redirects -status-code -silent | grep "[200]" | cut -d ' ' -f1 | sort -u > urls.txt
  echo -n "Number of live js files found: " && cat urls.txt | wc -l
}

#Open JSUrlFiles
open_jsurlfile() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Filtering JsFiles-links\e[0m\n"
  cat target.txt | httpx -follow-redirects -silent -status-code | grep "[200]" | cut -d ' ' -f1 | sort -u > urls.txt
}

#Gather Endpoints From JsFiles
endpoint_js() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started gathering Endpoints\e[0m"
  interlace -tL urls.txt -threads 5 -c "echo 'python3 ./tools/LinkFinder/linkfinder.py -d -i _target_ -o cli >> endpoints.txt" --silent
  echo -n "Number of endpoint found: " && cat endpoints.txt | wc -l
}

#Gather Secrets From Js Files
secret_js() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started Finding Secrets in JSFiles\e[0m"
  interlace -tL urls.txt -threads 5 -c "python3 ./tools/SecretFinder/SecretFinder.py -i _target_ -o cli >> jslinksecret.txt" --silent
  echo -n "Number of secrets found: " && cat jslinksecret.txt | wc -l
}

#Collect Js Files For Maually Search
getjsbeautify() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started to Gather JSFiles locally for Manual Testing\e[0m"
  mkdir -p jsfiles
  interlace -tL urls.txt -threads 5 -c "bash ./tools/getjsbeautify.sh _target_" --silent
#  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Manually Search For Secrets Using gf or grep in out/\e[0m\n"
  echo "List of JS downloaded:" && ls -l ./jsfiles/
}

#Gather JSFilesWordlist
wordlist_js() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started Gathering Words From JsFiles-links For Wordlist.\e[0m\n"
  cat urls.txt | python3 ./tools/getjswords.py >> temp_jswordlist.txt
  cat temp_jswordlist.txt | sort -u >> jswordlist.txt
  rm temp_jswordlist.txt
}

#Gather Variables from JSFiles For Xss
var_js() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started Finding Varibles in JSFiles For Possible XSS\e[0m\n"
  cat urls.txt | while read url; do bash ./tools/jsvar.sh $url | tee -a js_var.txt; done
}

#Find DomXSS
domxss_js() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Scanning JSFiles For Possible DomXSS\e[0m\n"
  interlace -tL urls.txt -threads 5 -c "bash ./tools/findomxss.sh _target_" --silent
}

#Generate Report
report() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Generating Report!\e[0m\n"
  bash report.sh
}

#Save in Output Folder
output() {
  mkdir -p $dir
  mv -vf endpoints.txt all_urls.txt jslinksecret.txt urls.txt jswordlist.txt js_var.txt domxss_scan.txt report.html $dir/
  mv -v jsfiles/ $dir/
  tar -cvf archive.tar $dir/
}

output() {
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

gather_js
endpoint_js
secret_js
getjsbeautify
wordlist_js
var_js
domxss_js
report
dir=$OUTPUT_DIR
output
send_to_issue