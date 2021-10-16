require 'devise'
require 'devise-encryptable'
Devise.secret_key = SecureRandom.hex(50)

module Amz
  module Auth
    mattr_accessor :default_secret_key

    def self.config
      yield(Amz::Auth::Config)
    end
  end
end

Amz::Auth.default_secret_key = Devise.secret_key
