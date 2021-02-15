# github.com/m4ll0k

import sys
import jsbeautifier
import requests


def beauty(content):
    return jsbeautifier.beautify(content.decode())


def getjs(url):
    http_response = requests.get(url)
    if http_response.status_code != 200:
        return None
    return http_response


def main():
    if len(sys.argv) != 3:
        sys.exit(print("\nUsage:\tpython3 {0} <url> <output>\n".format(sys.argv[0])))
    url = sys.argv[1]
    output = sys.argv[2]
    if '.js' in url:
        http_response = getjs(url)
        if http_response is not None:
            js = beauty(http_response.content)
            if output:
                _file = open(sys.argv[2], "w")
                _file.write(js)
                _file.close()
                print("Done! file saved here -> \"{0}\"".format(_file.name))
    else:
        sys.exit(print("\".js\" not found in URL ({}).. check your url".format(sys.argv[1])))

main()