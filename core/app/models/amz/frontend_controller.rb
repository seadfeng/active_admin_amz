module Amz
  class FrontendController < Amz::Base 
    has_many :widgets_controllers,->{ order('position asc') } , class_name: "Amz::WidgetsController", dependent: :delete_all, inverse_of: :controller, autosave: true, foreign_key: 'controller_id' 
    has_many :widgets, through: :widgets_controllers  
    with_options presence: true do  
      validates :name 
    end 
    validates_uniqueness_of :name, case_sensitive: true, allow_blank: false  

    def display_name
      self.presentation
    end
  end
end