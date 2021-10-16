 module Amz 
    module Backend
        module Authorization 
            CREATE_TICKET = :create_ticket 
            PUBLISH = :publish 
            DONE = :done 
            IMPORT = :import
            CLEAR = :clear
        end 
        Auth = Authorization
    end
end 
::ActiveAdmin::Authorization.send(:include, Amz::Backend::Authorization)