
module Amz
  class BaseController < ApplicationController 
    include Amz::Core::ControllerHelpers::Auth
    include Amz::Core::ControllerHelpers::Image
    include Amz::Core::ControllerHelpers::Common 
    include Amz::Core::ControllerHelpers::Search 
    include Amz::Core::ControllerHelpers::Store  
    # include Amz::Core::ControllerHelpers::AuthenticationHelpers
    # include Amz::Core::ControllerHelpers::CurrentUserHelpers

    respond_to :html
  end
end
