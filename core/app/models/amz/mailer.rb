module Amz
  class Mailer < Amz::Base 
    belongs_to :store 
    has_many :mailer_logs, class_name: 'Amz::MailerLog'   

    with_options presence: true do 
      validates :subject, :store 
    end

    before_validation :check_available_on, if: :available_on_changed?
    before_destroy :validation_mailer_logs

    attr_accessor :mailer_template_id

    scope :available,  ->{  where( "#{Mailer.quoted_table_name}.available_on is not null and #{Mailer.quoted_table_name}.available_on < ? and #{Mailer.quoted_table_name}.completed_at is null" , Time.current)  } 
    scope :completed, ->{ where( "#{Mailer.quoted_table_name}.completed_at is not null") } 

    def mailer_template_id
      nil
    end

    def mailer_template_id=(data)
      unless data.blank?
        template = MailerTemplate.find data
        self.subject = template.subject
        self.body = template.body
      end
    end

    def completed_at? 
      !!completed_at
    end

    def build_mailer_logs
      unless mailer_logs.any? 
        subscriptions = Subscription.subscribed
        if only_user
          subscriptions = subscriptions.users
        end
        mailer_logs.create( subscriptions.ids.map{|id| { subscription_id: id } } )
      end
    end

    private 

    def validation_mailer_logs
      if mailer_logs.any?  
        throw(:abort)
        errors.add(:mailer_log_ids, :cant_not_destroy) 
      end
    end

    def check_available_on
      if completed_at? 
        throw(:abort)
        errors.add(:available_on, :email_has_send_completed) 
      end
    end
    
  end
end
