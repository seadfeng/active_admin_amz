module Amz
  class WidgetsContent < Amz::Base
    belongs_to :widget, class_name: 'Amz::Widget' 
    belongs_to :resource, polymorphic: true    

    validates_uniqueness_of :widget, case_sensitive: false , allow_blank: false,  scope: [:resource] 

    def display_name
      "#{widget.name} - #{resource.try(:name)||resource.try(:title)}"
    end
  end
end
