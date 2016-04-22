from urllib import urlencode
from urlparse import urlparse, parse_qs, ParseResult
import requests
from hmac_auth import HMACAuth

auth = HMACAuth("Ch7/DHoFIdIDaX5m4mqGxQ==", "6Ql2ZXcYqOGLdwwdWbcnCJq0N32hX8NA6AWr6wewx/T+oLcWOuynddnrETxkP9cHB7jXNs09NL3vY/BGeDxxWw==")

hostname = "localhost"
port = "3000"
https = False
base_endpoint = "api"

api_base = "http%s://%s%s/%s" % ("s" if https else "", hostname, ":" + port if port else "", base_endpoint)

def last_nonce():
    return int(requests.get("%s/last_nonce" % (api_base), auth=auth).text)

def add_nonce(url):
    nonce = last_nonce() + 1
    uri = urlparse(url)
    query = parse_qs(uri.query)
    if 'nonce' in query:
        del query['nonce']
    query['nonce'] = nonce
    query = urlencode(query, True)
    return ParseResult(uri.scheme, uri.netloc, uri.path, uri.params, query, uri.fragment).geturl()

url = "%s/test" % (api_base)
r = requests.get(add_nonce(url), auth=auth)
print r.text

r = requests.post(url, data={'data': 'post test', 'nonce': last_nonce() + 1}, auth=auth)
print r.text
