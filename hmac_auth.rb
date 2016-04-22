require 'openssl'
require 'base64'

class HMACAuth
  attr_reader :digest_algorithm, :public_key

  def initialize(digest_algorithm: 'sha512',
                 public_key:,
                 private_key:)
    self.digest_algorithm = OpenSSL::Digest.new(digest_algorithm)
    self.public_key = public_key
    self.private_key = private_key
  end

  def sign!(endpoint_path, method, headers, payload)
    add_md5_header(headers, payload) if payload && !md5_header_matches?(headers, payload)

    add_public_key_header(headers)
    add_signature_header(endpoint_path, method, headers, payload)

    headers
  end

  def valid?(endpoint_path, method, headers, payload)
    (payload.empty? || md5_header_matches?(headers, payload)) && find_header(headers, SIGNATURE_HEADERS) == signature(endpoint_path, method, headers, payload)
  end

  private

  PAYLOAD_MD5_HEADERS = %w[X-Payload-MD5 HTTP_X_PAYLOAD_MD5]
  PUBLIC_KEY_HEADERS  = %w[X-HMAC-Public-Key HTTP_X_HMAC_PUBLIC_KEY]
  SIGNATURE_HEADERS   = %w[X-HMAC-Signature HTTP_X_HMAC_SIGNATURE]

  def base64_md5_digest(string)
    Base64.strict_encode64(Digest::MD5.digest(string))
  end

  def base64_hmac_digest(string)
    Base64.strict_encode64(OpenSSL::HMAC.digest(digest_algorithm, private_key, string))
  end


  def find_header(headers, search)
    if search.is_a?(Array)
      find_header(headers, search.find { |key| find_header(headers, key) })
    else
      headers.fetch(search, nil) if search
    end
  end

  def add_header(headers, key, value)
    headers[key] = value
  end

  def md5_header_matches?(headers, payload)
    header = find_header(headers, PAYLOAD_MD5_HEADERS)
    base64_md5_digest(payload) == header if header
  end

  def add_md5_header(headers, payload)
    add_header(headers, PAYLOAD_MD5_HEADERS[0], base64_md5_digest(payload))
  end

  def add_public_key_header(headers)
    add_header(headers, PUBLIC_KEY_HEADERS[0], public_key)
  end

  def add_signature_header(endpoint_path, method, headers, payload)
    add_header(headers, SIGNATURE_HEADERS[0], signature(endpoint_path, method, headers, payload))
  end

  def signature(endpoint_path, method, headers, payload)
    base64_hmac_digest(canonical_string(endpoint_path, method, headers, payload))
  end

  def canonical_string(endpoint_path, method, headers, payload)
    [
      method.upcase,
      endpoint_path,
      find_header(headers, PAYLOAD_MD5_HEADERS),
    ].join("\0")
  end

  attr_accessor :private_key
  attr_writer :digest_algorithm, :public_key
end
