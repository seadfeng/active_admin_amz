class CreateAmzMailerTemplates < ActiveRecord::Migration[6.0]
  def up
    create_table :amz_mailer_templates do |t|
      t.belongs_to :locale
      t.string     :subject, null: false, default: ""
      t.string     :identity, null: false, default: ''
      t.text       :body 
      t.text       :style 
      t.datetime   :deleted_at
      t.timestamps
    end
    add_index :amz_mailer_templates, [:locale_id, :identity], name: 'amz_mailer_templates_identity_and_locale_id', unique: true, using: :btree
    add_index :amz_mailer_templates, :identity  
  end

  def down
    drop_table :amz_mailer_templates
  end
end
