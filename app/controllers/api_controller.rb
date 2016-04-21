class ApiController < ApplicationController
  before_action :api_authenticate

  def api_authenticate
    keys = ApiKey.find_by_public(ApiAuth.access_id(request))
    head(:unauthorized) unless keys && ApiAuth.authentic?(request, keys.secret)
  end
end
