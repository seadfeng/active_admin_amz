module Amz
  class MailerLog < Amz::Base 
    belongs_to :mailer
    belongs_to :subscription

    validates_uniqueness_of :mailer, case_sensitive: true, allow_blank: false, scope: [:subscription]  

    scope :sended,  ->{  where( "#{MailerLog.quoted_table_name}.sended_at is not null")  } 
    scope :not_sended,  ->{  where( "#{MailerLog.quoted_table_name}.sended_at is null")  } 
    scope :queued,  ->{  where( "#{MailerLog.quoted_table_name}.queued_at is not null")  } 
    scope :not_queued,  ->{  where( "#{MailerLog.quoted_table_name}.queued_at is null")  } 

    def send_mail
      Amz::SubscriptionMailer.with(subscription: subscription, mailer_log: self).market_instructions.deliver_later
      self.queued!
    end

    def sended!
      update_attribute(:sended_at, Time.current)
    end

    def queued!
      update_attribute(:queued_at, Time.current)
    end

  end
end
