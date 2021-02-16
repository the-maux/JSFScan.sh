#!/bin/bash

# Todo check if the output directory already exist, caused it failed if yes
# Todo make a proctection when no .js file are found, to avoir the infinite loop in C.I

echo -e "\e[36m _______ ______ _______ ______                          _     \e[0m"
echo -e "\e[36m(_______/ _____(_______/ _____)                        | |    \e[0m"
echo -e "\e[36m     _ ( (____  _____ ( (____   ____ _____ ____     ___| |__  \e[0m"
echo -e "\e[36m _  | | \____ \|  ___) \____ \ / ___(____ |  _ \   /___|  _ \ \e[0m"
echo -e "\e[36m| |_| | _____) | |     _____) ( (___/ ___ | | | |_|___ | | | |\e[0m"
echo -e "\e[36m \___/ (______/|_|    (______/ \____\_____|_| |_(_(___/|_| |_|\e[0m\n"

#Gather JSFilesUrls
gather_js() {
  cat target.txt | gau | grep -iE "\.js$" | sort | uniq > gau_urls.txt
  echo -e "\nGau found:  $(cat gau_urls.txt | wc -l) file(s)"
  cat target.txt | subjs > subjs_url.txt
  echo -e "subjs found: $(cat subjs_url.txt | wc -l) file(s)\nFiltering duplicate and wih httpx removing dead link"
  #cat target.txt | hakrawler -js -depth 2 -scope subs -plain >> hakrawler_urls.txt
  #echo -n "With subjs found: " && cat hakrawler_urls.txt | wc -l && echo "Filtering wih httpx for live js"
  cat gau_urls.txt > all_urls.txt && cat subjs_url.txt >> all_urls.txt # && cat hakrawler_urls.txt >> all_urls.txt
  cat all_urls.txt | httpx -follow-redirects -status-code -silent | grep "[200]" | cut -d ' ' -f1 | sort | uniq > urls.txt
  number_of_file_found=$(cat urls.txt | wc -l)
  echo "Number of live js files found: $((number_of_file_found))"
  if [ $number_of_file_found = "0" ]
  then
          echo "No file found, Exiting..."
          exit 1
  fi
}

#Gather Endpoints From JsFiles
endpoint_js() {
  interlace -tL urls.txt -threads 5 -c "python3 ./tools/LinkFinder/linkfinder.py -d -i _target_ -o cli >> all_endpoints.txt" --silent --no-bar
  number_of_endpoint_found=$(cat all_endpoints.txt | wc -l)
  if [ $number_of_endpoint_found = "0" ]
  then
          echo "No endpoint found, Exiting..."
          exit 1
  fi
  cat all_endpoints.txt | sort | uniq > endpoints.txt
  echo "Number of endpoint found: $(cat endpoints.txt | wc -l)"
  #cat endpoints.txt
}

#Gather Secrets From Js Files
secret_js() {
  interlace -tL urls.txt -threads 5 -c "python3 ./tools/SecretFinder/SecretFinder.py -i _target_ -o cli >> jslinksecret.txt" --silent --no-bar
  echo -n "Number of secrets found: " && cat jslinksecret.txt | wc -l
}

#Collect Js Files For Maually Search
getjsbeautify() {
  mkdir -p jsfiles
  head -5 script.bash > urls_tmp.txt
  interlace -tL urls_tmp.txt -threads 1 -c "echo './tools/getjsbeautify.sh _target_'" --silent --no-bar
#  echo -e "\n\e[36m[\e[32m+\e[36m]\e[92m Manually Search For Secrets Using gf or grep in out/\e[0m\n"
  echo "Getjsbeautify downloaded $(ls -l ./jsfiles/ | wc -l) files"
}

#Gather JSFilesWordlist
wordlist_js() {
  cat urls.txt | python3 ./tools/getjswords.py >> temp_jswordlist.txt
  cat temp_jswordlist.txt | sort -u >> jswordlist.txt
  rm temp_jswordlist.txt
}

#Gather Variables from JSFiles For Xss
var_js() {
  cat urls.txt | while read url; do bash ./tools/jsvar.sh $url | tee -a js_var.txt; done
}

#Find DomXSS
domxss_js() {
  interlace -tL urls.txt -threads 5 -c "bash ./tools/findomxss.sh _target_" --silent --no-bar
}


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
  echo -e "\e[36m[+] Started Gathering JsFiles-links with gau & subjs & hakrawler \e[0m"
  echo "Searching JSFiles on target(s):" && cat target.txt
  gather_js
  echo -e "\e[36m[+] Started gathering Endpoints\e[0m"
  endpoint_js
  echo -e "\e[36m[+] Started to Gather JSFiles locally for Manual Testing\e[0m"
  getjsbeautify
#  echo -e "\e[36m[+] Started Gathering Words From JsFiles-links For Wordlist.\e[0m"
#  wordlist_js
#  echo -e "\e[36m[+] Started Finding Varibles in JSFiles For Possible XSS\e[0m"
#  var_js
}


analyse() {
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

