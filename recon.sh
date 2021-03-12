#!/usr/bin/env bash

deep_and_long_recon() {
  cat target.txt | sed 's$https://$$' | chaos -silent | waybackurls | httpx -silent > chaos.txt
  # TOOLONG: xargs -I@ -P20 sh -c 'gospider -a -s "@" -d 2' | grep -Eo "(http|https)://[^/"].*.js+" | sed "s#] > chaos.txt #TODO add in all urls.txt
  echo -e "(INFO) chaos + wayback found: $(cat chaos.txt | wc -l) url(s)"

  # Removing hakrawler, cause its take too long for github actions ... more than 6hours :(
  #  cat target.txt | hakrawler -js -plain -usewayback -depth 3 -scope subs | unew > hakrawlerHttpx.txt
  #  echo -e "(INFO) hakrawler + wayback found: $(cat hakrawlerHttpx.txt | wc -l) url(s)"

  #cat target.txt | sed 's$https://$$' | assetfinder -subs-only | httpx -timeout 3 -threads 300 --follow-redirects -silent | sort -u > assetfinder_urls.txt
  #TOLONG: | xargs -I% -P10 sh -c 'hakrawler -plain -linkfinder -depth 5 -url %' | awk '{print $3}' | grep -E "\.js(?:onp?)?$" |

  # TOKNOW: gospider is not working good without the "https://"
  #gospider -a -w -r -S target.txt -d 3 | grep -Eo "(http|https)://[^/\"].*\.js+" | sed "s#\] \- #\n#g" > gospider_url.txt
  #echo -e "(INFO) gospider individually found: $(cat gospider_url.txt | wc -l) url(s)"
}

use_recontools_individualy() {
  #TODO: combine all this tool to maximize the result, for the just run 1 by 1 than filtering result for duplicates
  target=$(head -n 1 target.txt | sed 's$https://$$')

  subfinder -d $target -silent > subfinder.txt
  echo -e "(INFO) subfinder found: $(cat subfinder.txt | wc -l) subdomain(s)"

  python3 ./tools/Sublist3r/sublist3r.py -d $target -o sublist3r.txt &> nooutput
  echo -e "(INFO) sublist3r found: $(cat sublist3r.txt | wc -l) subdomain(s)"

  python3 ./tools/SubDomainizer/SubDomainizer.py -l target.txt -o SubDomainizer.txt -san all  &> nooutput
  echo -e "(INFO) SubDomainizer found: $(cat SubDomainizer.txt | wc -l) subdomain(s)"

  cat sublist3r.txt >> SubDomainizer.txt
  cat subfinder.txt >> SubDomainizer.txt
  cat SubDomainizer.txt | sed 's$www.$$' | sort -u > urls_no_http.txt
  echo -e "(INFO) After filtering duplicate, $(cat urls_no_http.txt | wc -l) subdomain(s) found"

  # Using chaos + waybackurls
  cat target.txt | sed 's$https://$$' | chaos -silent | waybackurls | httpx -silent > chaos.txt
  echo -e "(INFO) chaos + wayback found: $(cat chaos.txt | wc -l) url(s)"

  # Using gau
  cat target.txt | gau | grep -iE "\.js$" | sort -u > gau_solo_urls.txt
  echo -e "(INFO) gau individually found: $(cat gau_solo_urls.txt | wc -l) url(s)"

  #TOKNOW: assetfinder is not working good with "https://"
  cat target.txt | sed 's$https://$$' | assetfinder -subs-only | httpx -timeout 3 -threads 300 --follow-redirects -silent | sort -u > assetfinder_urls.txt
  echo -e "(INFO) assetfinder individually found: $(cat assetfinder_urls.txt | wc -l) url(s)"

  # Using hakrawler
  cat target.txt | hakrawler -js -depth 2 -scope subs -plain > hakrawler_urls.txt
  echo -e "(INFO) hakrawler individually found: $(cat hakrawler_urls.txt | wc -l) url(s)"
}

#Gather new endpoints From domain / path / JsFiles found
search_jsFile_from_domain_found() {
  # Using subjs
  cat gau_solo_urls.txt | subjs > subjs_url.txt
  echo -e "(INFO) gau + subjs found: $(cat subjs_url.txt | wc -l) url(s)"

  echo "Searching with jsubfinder on urls.txt, exemple of targets:"
  cat urls.txt | tail -n 50
  cat urls.txt | jsubfinder > jsubfinder.txt #TODO add in all urls.txt
  echo -e "(INFO) jsubfinder individually found: $(cat jsubfinder.txt | wc -l) url(s)"

  # TOKNOW: linkfinder doesnt work if https is not present
  cat urls_no_http.txt
  cat urls_no_http.txt | sed 's$https://$$' | awk '{print "https://" $0}' > search_endpoint.txt # tobe sur there are alway a https://
  interlace -tL search_endpoint.txt -threads 5 -c "python3 ./tools/LinkFinder/linkfinder.py -d -i '_target_' -o cli >> all_endpoints.txt" --silent --no-bar
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
  cat assetfinder_urls.txt >> all_urls.txt
  cat chaos.txt >>  all_urls.txt
  cat hakrawlerHttpx.txt >> all_urls.txt
  cat subj_gau_assetfinder.txt >> all_urls.txt

  number_of_file_found=$(cat all_urls.txt | wc -l)
  echo "(INFO) Before filtering duplicate/offline/useless files, we found: $((number_of_file_found)) files to analyse"
  # filtering dead link
  cat all_urls.txt | httpx -follow-redirects -status-code -silent | grep "[200]" | cut -d ' ' -f1 > urls_alive.txt
  # filtering duplicate & libs with no impact
  cat urls_alive.txt | awk -F '?' '{ print $1 }' | grep -v "jquery" | grep $(cat target.txt | sed 's$https://$$') | unew > urls.txt
  number_of_file_found=$(cat urls.txt | wc -l)
  echo "(INFO) Result of filters: Found $((number_of_file_found)) javascripts files to analyse"

  cat urls.txt | grep $(cat target.txt | sed 's$https://$$') > urls_filter.txt  # Only take if target domain is present
  number_of_file_found_post_filter=$(cat urls_filter.txt | wc -l)
  echo "(INFO) Result of BIG filters: Found $((number_of_file_found_post_filter)) javascripts files to analyse"

  if [ $number_of_file_found = "0" ]
  then
      echo "(ERROR) No JS file found during recon, Exiting..."
      exit 1
  fi
}

recon() {  # Try to gain the maximum of uniq JS file from the target
  echo "Searching JSFiles on target(s):" && cat target.txt
  echo -e "\n\e[36m[+] Searching with chaos & gau & subjs & hakrawler & assetfinder & gospider \e[0m"
  use_recontools_individualy # result in gau_solo_urls.txt subjs_url.txt hakrawler_urls.txt gospider_url.txt
  echo -e "\e[36m[+] Searching JsFiles-links mixing gau & subjs & assetfinder \e[0m"
  #deep_and_long_recon
  echo -e "\e[36m[+] Started gathering Js files from domain and path found \e[0m"
  search_jsFile_from_domain_found
  echo -e "\e[36m[+] Filtering results \e[0m"
  regroup_found_and_filter
  cat urls.txt > report.html
  echo -e "\e[36m[+] Sending result by mail \e[0m"
  python3 tools/sendReportByMail.py
}

recon

