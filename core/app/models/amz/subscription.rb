module Amz
  class Subscription < Amz::Base
    include Validates 
    belongs_to :store 
    belongs_to :user, class_name: 'Amz::User'
    acts_as_paranoid

    with_options presence: true do 
      validates :email , email: true
    end
    validates_uniqueness_of :email, case_sensitive: true, allow_blank: false, scope: [:store]  

    before_create :generate_unsubscribe_token 

    before_destroy :check_user



    scope :unsubscribed, -> { where( "#{Subscription.quoted_table_name}.unsubscribe_at is not null" )  }  
    scope :subscribed, -> { where( "#{Subscription.quoted_table_name}.unsubscribe_at is null" )  }   
    scope :guest, -> { where( "#{Subscription.quoted_table_name}.user_id is null" )  }   
    scope :users, -> { where( "#{Subscription.quoted_table_name}.user_id is not null" )  }   


    def generate_unsubscribe_token
     self.unsubscribe_token = Devise.friendly_token
    end

    def unsubscribed? 
      !!unsubscribe_at
    end

    def subscribed? 
      !unsubscribe_at
    end

    def unsubscribe!
      update_attribute(:unsubscribe_at, Time.current)
      if user
        user.update_attribute(:subscription, false) 
      end
    end 

    def subscribe!
      
      if unsubscribed? 
        update_attribute(:unsubscribe_at, nil)  
        Amz::SubscriptionMailer.with(subscription: self).notification_instructions.deliver_later
      end
      
      if user
        user.update_attribute(:subscription, true)  
      end
    end 

    def guest?
      user.nil?
    end

    private  

    def check_user 
      if user.present?
        throw(:abort)
        errors.add(:email, :cannot_destroy_if_has_user) 
      end
    end

  end
end 
