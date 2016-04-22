require './hmac-auth'
class ApiController < ApplicationController
  before_action :api_authenticate
  before_action :check_nonce, except: [:last_nonce]
  skip_before_filter :verify_authenticity_token

  def last_nonce
    render inline: @keys.last_nonce.to_i.to_s
  end

  private

  def api_authenticate
    endpoint_path = request.fullpath
    method = request.request_method
    headers = request.env
    payload = request.raw_post

    @keys = ApiKey.find_by_public(request.env['HTTP_X_HMAC_PUBLIC_KEY'])
    head(:unauthorized) unless @keys && HMACAuth.new(public_key: @keys.public, private_key: @keys.secret).valid?(endpoint_path, method, headers, payload)
  end

  def check_nonce
    nonce = params.delete(:nonce).to_i
    return head(:invalid) unless nonce && nonce > @keys.last_nonce.to_i
    @keys.last_nonce = nonce
    @keys.save
  end
end
