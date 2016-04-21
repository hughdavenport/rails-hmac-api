require 'api-auth'
require 'rest-client'

def api_base
  hostname = "localhost"
  port = "3000"
  https = false
  base_endpoint = "api"

  "http#{'s' if https}://#{hostname}#{":#{port}" if port}/#{base_endpoint}"
end

public_token = "Ch7/DHoFIdIDaX5m4mqGxQ=="
secret_token = "6Ql2ZXcYqOGLdwwdWbcnCJq0N32hX8NA6AWr6wewx/T+oLcWOuynddnrETxkP9cHB7jXNs09NL3vY/BGeDxxWw=="

RestClient.add_before_execution_proc do |request, params|
  ApiAuth.sign!(request, public_token, secret_token)
end

def last_nonce
  "#{RestClient.get "#{api_base}/last_nonce"}".to_i
end

def add_nonce(url)
  nonce = last_nonce + 1
  uri = URI.parse(url)
  params = uri.query ? uri.query.split("&").reject { |p| p.split("=")[0] == "nonce" } : []
  params << "nonce=#{nonce}"
  uri.query = params.join("&")
  uri.to_s
end

url = "#{api_base}/test"
response = RestClient.get add_nonce(url)
puts response
