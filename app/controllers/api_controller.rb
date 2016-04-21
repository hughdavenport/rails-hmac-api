class ApiController < ApplicationController
  before_action :api_authenticate
  before_action :check_nonce, except: [:last_nonce]

  def last_nonce
    render inline: @keys.last_nonce.to_i.to_s
  end

  private

  def api_authenticate
    @keys = ApiKey.find_by_public(ApiAuth.access_id(request))
    head(:unauthorized) unless @keys && ApiAuth.authentic?(request, @keys.secret)
  end

  def check_nonce
    nonce = params.delete(:nonce).to_i
    return head(:invalid) unless nonce && nonce > @keys.last_nonce.to_i
    @keys.last_nonce = nonce
    @keys.save
  end
end
