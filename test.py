from datetime import datetime
from time import mktime
from wsgiref.handlers import format_date_time
from requests.auth import AuthBase
from base64 import b64encode
from urllib import urlencode
from urlparse import urlparse, parse_qs, ParseResult
import re
import requests
import hashlib
import hmac

public_token = "Ch7/DHoFIdIDaX5m4mqGxQ=="
secret_token = "6Ql2ZXcYqOGLdwwdWbcnCJq0N32hX8NA6AWr6wewx/T+oLcWOuynddnrETxkP9cHB7jXNs09NL3vY/BGeDxxWw=="

auth = HMACAuth(public_token, secret_token)

hostname = "localhost"
port = "3000"
https = False
base_endpoint = "api"

api_base = "http%s://%s%s/%s" % ("s" if https else "", hostname, ":" + port if port else "", base_endpoint)

class HMACAuth(AuthBase):
    def __init__(self, public_token, secret_token):
        self.public_token = public_token
        self.secret_token = secret_token

    def __call__(self, r):
        self.add_auth_header(r)
        return r

# Based on the api-auth ruby gem, which was released under MIT license, see https://raw.githubusercontent.com/mgomes/api_auth/v1.5.0/LICENSE.txt

    def add_auth_header(self, r):
        r.headers['Authorization'] = self.auth_header(r)

    def auth_header(self, r):
        return "APIAuth %s:%s" % (self.public_token, self.hmac_signature(r))

    def hmac_signature(self, r):
        return b64encode(hmac.new(self.secret_token, self.canonical_string(r), hashlib.sha1).digest())

    def canonical_string(self, r):
        return ",".join([
#            self.method(r),
            self.content_type(r),
            self.content_md5(r),
            self.uri(r),
            self.date(r)
        ])

    def find_header(self, r, l):
        for header in l:
            for key, value in r.headers.iteritems():
                if key.upper() == header:
                    return value
        return ""

    def method(self, r):
        return r.method.upper()

    def content_type(self, r):
        return self.find_header(r, "CONTENT-TYPE CONTENT_TYPE HTTP_CONTENT_TYPE".split())

    def content_md5(self, r):
        md5 = self.find_header(r, "CONTENT-MD5 CONTENT_MD5".split())
        if not md5 and self.method(r) in "POST PUT".split():
            md5 = self.add_content_md5_header(r)
        return md5

    def uri(self, r):
        url = re.sub(r'https?://[^,?/]*', '', r.url)
        return url if url else "/"

    def date(self, r):
        date = self.find_header(r, "DATE HTTP_DATE".split())
        if not date:
            date = self.add_date_header(r)
        return date

    def add_content_md5_header(self, r):
        m = hashlib.md5()
        m.update(r.body if r.body else "")
        md5 = m.hexdigest()
        r.headers['Content-MD5'] = md5
        return md5

    def add_date_header(self, r):
        date = format_date_time(mktime(datetime.now().timetuple()))
        r.headers['Date'] = date
        return date

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
