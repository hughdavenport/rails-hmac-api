class User < ActiveRecord::Base
  has_many :api_keys, dependent: :destroy
end
