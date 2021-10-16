module Amz
    module Api
        class BaseController < ApplicationController 
            before_action :load_auth 
            respond_to :json
            skip_before_action :verify_authenticity_token
            
            private 

            def render_403
                response.status = 403 
                render json: { status: 403 }
            end
        
            def load_auth 
                auth_key    = request.headers["X-Auth-Key"] 
                @api = Amz::ApiToken.api_token_cache(auth_key) 
                if @api.blank? 
                  return render_403
                end
            end
        end
    end
end