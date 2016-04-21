class ApiKey < ActiveRecord::Base
  belongs_to :user

  after_initialize :generate_keys

  def generate_keys
    self.secret ||= ApiAuth.generate_secret_key
    self.public ||= SecureRandom.base64
  end
end
