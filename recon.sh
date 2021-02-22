#!/usr/bin/env bash

#Gather JSFilesUrls with gau / subjs / assetfinder / gospider / hakrawler
use_recontools_individualy() {
  # TOKNOW: assetfinder is not working good with "https://"
  cat target.txt | gau | grep -iE "\.js$" | sort -u > gau_solo_urls.txt
  echo -e "(DEBUG) gau individually found: $(cat gau_solo_urls.txt | wc -l) url(s)"

  cat gau_solo_urls.txt | subjs > subjs_url.txt
  echo -e "(DEBUG) gau + subjs found: $(cat subjs_url.txt | wc -l) url(s)"

  cat target.txt | hakrawler -js -depth 2 -scope subs -plain > hakrawler_urls.txt
  echo -e "(DEBUG) hakrawler individually found: $(cat hakrawler_urls.txt | wc -l) url(s)"

  # TOKNOW: gospider is not working good without the "https://"
  gospider -a -w -r -S target.txt -d 3 | grep -Eo "(http|https)://[^/\"].*\.js+" | sed "s#\] \- #\n#g" > gospider_url.txt
  echo -e "(DEBUG) gospider individually found: $(cat gospider_url.txt | wc -l) url(s)"

  cat target.txt | httpx --silent | jsubfinder -s > jsubfinder.txt #TODO add in all urls.txt
  echo -e "(DEBUG) jsubfinder individually found: $(cat jsubfinder.txt | wc -l) url(s)"

  cat target.txt | sed 's$https://$$' | assetfinder -subs-only | httpx -timeout 3 -threads 300 --follow-redirects -silent | xargs -I% -P10 sh -c 'hakrawler -plain -linkfinder -depth 5 -url %' | awk '{print $3}' | grep -E "\.js(?:onp?)?$" | sort -u > assetfinder_urls.txt
  echo -e "(DEBUG) assetfinder individually found: $(cat assetfinder_urls.txt | wc -l) url(s)"

  cat target.txt | chaos -silent | httpx -silent | xargs -I@ -P20 sh -c 'gospider -a -s "@" -d 2' | grep -Eo "(http|https)://[^/"].*.js+" | sed "s#] > chaos.txt #TODO add in all urls.txt
  echo -e "(DEBUG) chaos + wayback found: $(cat chaos.txt | wc -l) url(s)"

  cat target.txt | rush -j 100 'hakrawler -js -plain -usewayback -depth 6 -scope subs -url {} | unew > hakrawlerHttpx.txt'
  echo -e "(DEBUG) hakrawler + wayback found: $(cat hakrawlerHttpx.txt | wc -l) url(s)"

}

combine_assetfinder_gau_subjs() {  # mixing assetfinder + gau + subjs together
  cat target.txt | sed 's$https://$$' > urls_no_http.txt  # remove https cause assetfinder doesnt like it

  cat urls_no_http.txt | assetfinder | sort -u > assetfinder.txt
  echo -e "(DEBUG) assetfinder found: $(cat assetfinder.txt | wc -l) subdomain (s)"

  cat assetfinder.txt | gau -subs -b png,jpg,jpeg,html,txt,JPG | sort -u > gau.txt
  echo -e "(DEBUG) assetfinder + gau found: $(cat gau.txt | wc -l) url(s)"

  cat gau.txt | subjs | grep -v '?v=' | sort -u > subj_gau_assetfinder.txt
  echo -e "(DEBUG) assetfinder + gau + subjs found: $(cat subjs.txt | wc -l) javascript file(s)"
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

regroup_found_and_filter() {
  cat gau_solo_urls.txt > all_urls.txt
  cat subjs_url.txt >> all_urls.txt
  cat hakrawler_urls.txt >> all_urls.txt
  cat gospider_url.txt >> all_urls.txt
  cat jsubfinder.txt >> all_urls.txt
  cat assetfinder_urls.txt >> all_urls.txt
  cat chaos.txt >>  all_urls.txt
  cat hakrawlerHttpx.txt >> all_urls.txt
  cat subj_gau_assetfinder.txt >> all_urls.txt

  echo "(INFO) Removing dead links with httpx & filtering duplicate url"
  cat all_urls.txt | httpx -follow-redirects -status-code -silent | grep "[200]" | cut -d ' ' -f1 | sort -u | grep -v '?v=' > urls_alive.txt

  cat urls_alive.txt | grep -v "jquery" > urls.txt  # filtering classic lib with no impact
  number_of_file_found=$(cat urls.txt | wc -l)
  echo "(INFO) After filtering duplicate/offline/boring js files, we found: $((number_of_file_found)) files to analyse"

  if [ $number_of_file_found = "0" ]
  then
      echo "(ERROR) No JS file found during recon, Exiting..."
      exit 1
  fi
  cat urls.txt
}

recon() {  # Try to gain the maximum of uniq JS file from the target
  echo "Searching JSFiles on target(s):" && cat target.txt
  echo -e "\n\e[36m[+] Searching JsFiles-links individualy gau & subjs & hakrawler & assetfind & gospider \e[0m"
  use_recontools_individualy # result in gau_solo_urls.txt subjs_url.txt hakrawler_urls.txt gospider_url.txt
#  echo -e "\e[36m[+] Searching JsFiles-links mixing gau & subjs & assetfinder \e[0m"
#  combine_assetfinder_gau_subjs  # result in subjs.txt
#  echo -e "\e[36m[+] Started gathering Endpoints\e[0m"
#  endpoint_js
  regroup_found_and_filter
}

recon