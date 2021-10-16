module Amz
    module PermittedAttributes
      ATTRIBUTES = [
        :user_attributes, 
      ]
      mattr_reader *ATTRIBUTES

      @@user_attributes = [
        :id, :first_name, :last_name, :email, :store_id, :password, :password_confirmation, :subscription, :current_password
      ]
    end
end
