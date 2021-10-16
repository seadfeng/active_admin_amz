module Amz
    class Product < Amz::Base
        module StateMachine
            extend ActiveSupport::Concern
            included do  
                # include AASM
                
                state_machine :state, initial: :import do
                    before_transition [:draft ] => :published, :do => :touch_available_on
                    # before_transition :published => :draft, :do => :touch_draft
                    before_transition :published => :closed, :do => [:touch_discontinue_on ]
                    before_transition [:closed, :trash]=> :published, :do => [:touch_discontinue_on_nil, :touch_available_on]
 
                    event :move_to_trash do
                        transition  :published  => :trash 
                    end
                    event :move_to_error do 
                        transition  [:import]  => :error
                    end
                    event :move_to_draft do 
                        transition  [:error, :import]  => :draft
                    end

                    event :publish do 
                        transition [:draft,  :closed, :trash]  => :published
                    end 

                    event :close do 
                        transition :published => :closed
                    end  

                    
                    state :import
                    state :draft 
                    state :closed do
                        # validate :validate_closed 
                        # To do
                    end
                    state :trash
                    state :published do 
                        validate :validate_published 
                    end
                    state :error do
                        validate :validate_asin_image 
                    end 
                end 
                 
                # validate
                def validate_published 
                    errors.add(:state, :cannot_published_if_none_asin) if amazon && (amazon.asin.blank? ||  amazon.asin_image.blank? )
                    errors.add(:state, :cannot_published_if_deleted) if deleted? 
                    # errors.add(:amazon, :cannot_published_if_discontinued) if discontinued? 
                end  

                def validate_asin_image
                    errors.add(:state, :cannot_move_to_error_if_asin_image) if amazon && amazon.asin_image
                end

                private 

                def touch_available_on 
                    self.available_on = Time.current
                end
                def touch_available_on_nil 
                    self.available_on = nil
                end

                def touch_discontinue_on
                    self.discontinue_on = Time.current 
                end

                def touch_discontinue_on_nil
                    self.discontinue_on = nil
                end

                def touch_draft 
                    touch_available_on_nil
                end
            end
        end
    end
end
