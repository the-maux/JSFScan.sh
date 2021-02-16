# github.com/m4ll0k

import sys
import jsbeautifier
import requests
import json

URLS_FILE_PATH = "./tools/urls_tmp.txt"


def getjs(url):
    http_response = requests.get(url, verify=False)
    print("(GET) " + url, flush=True)
    if http_response.content is None:
        print("(ERROR) While downloading:" + url, flush=True)
        return http_response
    return http_response


def new_way():
    urls = list()
    with open(URLS_FILE_PATH, 'r') as f:
        for line in f:
            urls.append(line.strip())

    rax = 0
    for url in urls:
        if url.endswith('.js'):
            response = getjs(url)
            if response is not None:
                rax = rax + 1
                js = jsbeautifier.beautify(response.content.decode())
                with open(f"./tools/jsfiles/file-{rax}", "w") as outfile:
                    json.dump(js, outfile)
                print(f"Done! file saved here -> {outfile}", flush=True)


if __name__ == "__main__":
    new_way()
