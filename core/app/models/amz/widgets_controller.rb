module Amz
  class WidgetsController < Amz::Base
    belongs_to :widget, class_name: 'Amz::Widget' 
    belongs_to :controller, class_name: 'Amz::FrontendController' 

    def display_name
      "#{widget.name} - #{controller.name}"
    end
  end
end
