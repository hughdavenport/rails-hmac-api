from requests.auth import AuthBase
from base64 import b64encode
import re
import hashlib
import hmac

class HMACAuth(AuthBase):
    def __init__(self, public_key, private_key, digest_algorithm = 'sha512'):
        self.public_key = public_key
        self.private_key = private_key
        self.digest_algorithm = getattr(hashlib, digest_algorithm)

    def __call__(self, r):
        self.add_md5_header(r)
        self.add_public_key_header(r)
        self.add_signature_header(r)
        return r

# Based on the api-auth ruby gem, which was released under MIT license, see https://raw.githubusercontent.com/mgomes/api_auth/v1.5.0/LICENSE.txt

    def find_header(self, r, l):
        for header in l:
            for key, value in r.headers.iteritems():
                if key.upper() == header:
                    return value
        return ""

    def add_header(self, r, key, value):
        r.headers[key] = value

    def add_md5_header(self, r):
        if self.method(r) in "POST PUT".split():
            m = hashlib.md5()
            m.update(r.body if r.body else "")
            md5 = m.hexdigest()
            self.add_header(r, 'X-Payload-MD5', md5)

    def add_public_key_header(self, r):
        self.add_header(r, 'X-HMAC-Public-Key', self.public_key)

    def add_signature_header(self, r):
        self.add_header(r, 'X-HMAC-Signature', self.signature(r))

    def signature(self, r):
        return b64encode(hmac.new(self.private_key, self.canonical_string(r), self.digest_algorithm).digest())

    def canonical_string(self, r):
        return "\0".join([
            self.method(r),
            self.uri(r),
            self.payload_md5(r),
        ])

    def method(self, r):
        return r.method.upper()

    def payload_md5(self, r):
        return self.find_header(r, "X-PAYLOAD-MD5")

    def uri(self, r):
        url = re.sub(r'https?://[^,?/]*', '', r.url)
        return url if url else "/"
