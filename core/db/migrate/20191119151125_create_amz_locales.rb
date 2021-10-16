class CreateAmzLocales < ActiveRecord::Migration[6.0]
  def change
    
    create_table :amz_locales do |t|
      t.string  :name, 		 null: false, default: ""
      t.string  :code, 		 null: false, default: ""
      t.integer :position,	 null: false, default: 0 
      t.timestamps
      t.index ["code"], name: "index_locales_on_code", unique: true
      t.index ["name"], name: "index_locales_on_name", unique: true 
    end  

    unless locale = Amz::Locale.first

      locale = Amz::Locale.new
      locale.name = "English (United States)"
      locale.code = "en-US" 
      locale.position = 1
      locale.save!

      locale = Amz::Locale.new
      locale.name = "English (United Kingdom)"
      locale.code = "en-GB" 
      locale.position = 2
      locale.save!

      locale = Amz::Locale.new
      locale.name = "English (Australia)"
      locale.code = "en-AU" 
      locale.position = 3
      locale.save!

      locale = Amz::Locale.new
      locale.name = "English (Canada)"
      locale.code = "en-CA" 
      locale.position = 4
      locale.save!

      locale = Amz::Locale.new
      locale.name = "English (India)"
      locale.code = "en-IN" 
      locale.position = 5
      locale.save! 

      locale = Amz::Locale.new
      locale.name = "Spanish (Spain)"
      locale.code = "es-ES" 
      locale.position = 6
      locale.save!

      locale = Amz::Locale.new
      locale.name = "Spanish (Mexico)"
      locale.code = "es-MX" 
      locale.position = 7
      locale.save!
    end
  end
end
