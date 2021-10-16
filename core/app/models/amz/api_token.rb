module Amz
  class ApiToken < Amz::Base
    include Amz::Core::TokenGenerator 
    acts_as_paranoid

    before_validation :set_token 

    after_commit :clear_cache   

    with_options presence: true do 
      validates_uniqueness_of :key, allow_blank: false  
      validates :name    
    end  

    def self.api_token_cache(token)
      
      find_api_token = Rails.cache.fetch("api_token_key_#{token}") do
        ApiToken.find_by_key(token)
      end 
      
      if find_api_token.blank?
        Rails.cache.delete( "api_token_key_#{token}" ) 
        nil
      else
        find_api_token
      end
      
    end 

    private

    def clear_cache
      Rails.cache.delete( "api_token_key_#{self.key}" ) 
    end

    def set_token
      self.key = generate_token if self.key.blank?
    end

  end
end
