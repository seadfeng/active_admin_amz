Devise.setup do |config| 

    # Configure the class responsible to send e-mails.
    config.mailer = 'Amz::UserMailer'
    config.parent_controller = 'Amz::StoreController'
    config.allow_unconfirmed_access_for = nil
    # ==> ORM configuration
    # Load and configure the ORM. Supports :active_record (default) and
    # :mongoid (bson_ext recommended) by default. Other ORMs may be
    # available as additional gems.
    require 'devise/orm/active_record'

end
