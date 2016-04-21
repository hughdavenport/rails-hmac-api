require 'api-auth'
require 'rest-client'

hostname = "localhost"
port = "3000"
https = false
base_endpoint = "api"
api_base = "http#{'s' if https}://#{hostname}#{":#{port}" if port}/#{base_endpoint}"

public_token = "Ch7/DHoFIdIDaX5m4mqGxQ=="
secret_token = "6Ql2ZXcYqOGLdwwdWbcnCJq0N32hX8NA6AWr6wewx/T+oLcWOuynddnrETxkP9cHB7jXNs09NL3vY/BGeDxxWw=="

RestClient.add_before_execution_proc do |request, params|
  ApiAuth.sign!(request, public_token, secret_token)
end
response = RestClient.get "#{api_base}/test"
puts response
