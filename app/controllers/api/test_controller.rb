module Api
  class TestController < ApiController
    def index
      render inline: "test"
    end
  end
end
