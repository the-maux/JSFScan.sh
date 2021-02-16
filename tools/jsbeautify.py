# github.com/m4ll0k

import sys
import jsbeautifier
import requests


def beauty(content):
    return jsbeautifier.beautify(content.decode())


def getjs(url):
    http_response = requests.get(url, verify=False)
    print("(GET) " + url, flush=True)
    if http_response.content is None:
        print("(ERROR) While downloading:" + url, flush=True)
        return http_response
    return http_response


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(print("\nUsage:\tpython3 {0} <url> <output>\n".format(sys.argv[0])))
    try:
        url = sys.argv[1]
        if url.endswith('.js'):
            response = getjs(url)
            if response is not None:
                js = beauty(response.content)
                _file = open(sys.argv[2], "w")
                _file.write(js)
                _file.close()
                print("Done! file saved here -> \"{0}\"".format(_file.name), flush=True)
            else:
                print("Cant continue", flush=True)
        else:
            print("\".js\" not found in URL ({}).. check your url".format(sys.argv[1]), flush=True)
    except Exception:
        print("(ERROR) Unknow error with " + sys.argv[2], flush=True)

