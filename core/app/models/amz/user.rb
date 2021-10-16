module Amz
  class User < Amz::Base
    #https://qiita.com/alokrawat050/items/5267e6ab0e274ad1188a
    belongs_to :store
    has_one :user_subscription, class_name: 'Amz::Subscription', autosave: true 

    acts_as_paranoid
    devise :database_authenticatable, :registerable, :recoverable, :confirmable,
           :rememberable, :trackable, :encryptable, encryptor: 'authlogic_sha512',
           :authentication_keys => [:store_id, :email],
           :reset_password_keys => [:store_id, :email] 

    devise :confirmable, :confirmation_keys => [:store_id, :email] if Amz::Auth::Config[:confirmable]
    devise :validatable if Amz::Auth::Config[:validatable] 

    before_validation :set_login
    after_destroy :scramble_email_and_password
    after_create :find_or_build_subscription, :if => :subscription? 
    before_validation :touch_subscription, :if => :email_changed?, only: [:update]
    before_validation :touch_subscription, :if => :subscription_changed?, only: [:update]

    validates_uniqueness_of   :email, case_sensitive: true, :with  => Devise.email_regexp,  :scope => [:store_id], :allow_blank => false 
    # validates_format_of       :email,    :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?
    # validates_presence_of     :password, :on=>:create
    # validates_confirmation_of :password, :on=>:create
    # validates_length_of       :password, :within => Devise.password_length, :allow_blank => true   
 
    def self.find_for_authentication(warden_conditions)  
      where(:email => warden_conditions[:email], :store_id => warden_conditions[:store_id]).first
    end 

    def send_devise_notification(notification, *args) 
      devise_mailer.send(notification, self, *args).deliver_later
    end   

    def subscription?
      subscription
    end

    def subscribe! 
      self.subscription = true
      self.save
    end

    def unsubscribe! 
      self.subscription = false
      self.save
    end

    protected 

    def password_required?
      !persisted? || password.present? || password_confirmation.present?
    end
 
    private 

    def find_or_build_subscription
      if user_subscription 
        user_subscription
      else
        find_subscription = store.subscriptions.find_by(email: self.email)
        if find_subscription.blank?
          user_subscription = build_user_subscription
          user_subscription.email = self.email 
          user_subscription.store_id = self.store.id 
          user_subscription
        else
          find_subscription.user_id = self.id
          find_subscription.save
        end
      end
    end

    def touch_subscription
      user_subscription = find_or_build_subscription 
      self.login = email
      if subscription 
        user_subscription.subscribe!
      else 
        user_subscription.unsubscribe!
      end
    end
 

    def set_login
      # for now force login to be same as email, eventually we will make this configurable, etc.
      self.login ||= email if email
    end

    def scramble_email_and_password
      self.email = SecureRandom.uuid + "@example.net"
      self.login = email
      self.password = SecureRandom.hex(8)
      self.password_confirmation = password
      save
    end
  end
end
