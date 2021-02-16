# github.com/m4ll0k

import sys
import jsbeautifier
import requests
import json
from threading import Thread

URLS_FILE_PATH = "./tools/urls_tmp.txt"


def getjs(url):
    http_response = requests.get(url, verify=False)
    print("(GET) " + url, flush=True)
    if http_response.content is None:
        print("(ERROR) While downloading:" + url, flush=True)
        return http_response
    return http_response


def thread_func(urls):
    for url in urls:
        if url.endswith('.js'):
            response = getjs(url)
            if response is not None:
                js = jsbeautifier.beautify(response.content.decode())
                nameFile = url.split('/')[-1]
                with open(f"./tools/jsfiles/file-{nameFile}", "w") as outfile:
                    json.dump(js, outfile)
                print(f"Done! file saved here -> {outfile.name}", flush=True)


def split(a, n):
    k, m = divmod(len(a), n)
    return (a[i * k + min(i, m):(i + 1) * k + min(i + 1, m)] for i in range(n))


def new_way():
    urls = list()
    listOfThread = list()
    with open(URLS_FILE_PATH, 'r') as f:
        for line in f:
            urls.append(line.strip())

    listOfurlsSplitted = list(split(urls, 5))

    for listOfurls in listOfurlsSplitted:
        t = Thread(target=thread_func, args=(listOfurls))
        listOfThread.append(t)
        t.start()
    for thread in listOfThread:
        thread.join()


if __name__ == "__main__":
    new_way()
