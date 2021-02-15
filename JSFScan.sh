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
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started Gathering JsFiles-links with gau & subjs & hakrawler \e[0m\n"
  echo -n "Will scan target in file target.txt, wich are:" && cat target.txt
  echo -n "Number of files found: " && cat all_urls.txt | wc -l
  cat target.txt | gau | grep -iE "\.js$" | uniq | sort >> all_urls.txt
  cat target.txt | subjs >> all_urls.txt
  #cat target.txt | hakrawler -js -depth 2 -scope subs -plain >> all_urls.txt
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Checking for live JsFiles-links\e[0m\n"
  cat all_urls.txt | httpx -follow-redirects -status-code | grep "[200]" | cut -d ' ' -f1 | sort -u > urls.txt
  echo -n "Number of live js files found: " && cat urls.txt | wc -l
}

#Open JSUrlFiles
open_jsurlfile() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Filtering JsFiles-links\e[0m\n"
  cat target.txt | httpx -follow-redirects -silent -status-code | grep "[200]" | cut -d ' ' -f1 | sort -u > urls.txt
}

#Gather Endpoints From JsFiles
endpoint_js() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started gathering Endpoints\e[0m\n"
  interlace -tL urls.txt -threads 5 -c "echo 'Scanning _target_ Now' ; python3 ./tools/LinkFinder/linkfinder.py -d -i _target_ -o cli >> endpoints.txt" --silent
}

#Gather Secrets From Js Files
secret_js() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started Finding Secrets in JSFiles\e[0m\n"
  interlace -tL urls.txt -threads 5 -c "python3 ./tools/SecretFinder/SecretFinder.py -i _target_ -o cli >> jslinksecret.txt" --silent
}

#Collect Js Files For Maually Search
getjsbeautify() {
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Started to Gather JSFiles locally for Manual Testing\e[0m\n"
  mkdir -p jsfiles
  interlace -tL urls.txt -threads 5 -c "bash ./tools/getjsbeautify.sh _target_" --silent
  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Manually Search For Secrets Using gf or grep in out/\e[0m\n"
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
}

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