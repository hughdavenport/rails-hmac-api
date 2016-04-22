module Api
  class TestController < ApiController
    def get
      render inline: "test"
    end
    def post
      render inline: params["data"]
    end
  end
end
