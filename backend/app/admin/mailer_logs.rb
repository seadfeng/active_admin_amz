 
ActiveAdmin.register Amz::MailerLog,  as: "MailerLog" do
    init_controller    
    actions :all, except: [:new, :edit, :destroy ] 
    menu priority: 60, parent: "Mailers"  

    scope :sended
    scope :not_sended

    index do
        selectable_column
        id_column
        column :mailer
        column :subscription 
        column :state
        column :queued_at
        column :sended_at
        column :created_at
        column :updated_at
        actions
    end

    filter :mailer_subject 
    filter :queued_at
    filter :sended_at
    filter :created_at
    filter :updated_at 

end 
    
