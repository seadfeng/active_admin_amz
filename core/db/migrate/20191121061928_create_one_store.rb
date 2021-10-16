class CreateOneStore < ActiveRecord::Migration[6.0]
  def change
    unless store = Amz::Store.first 
      Amz::Store.new do |s|
        s.name = "Amz Demo Site"
        s.url = "https://demo.example.com"
        s.domain = "demo.example.com"
        s.code = "amz"
        s.locale = Amz::Locale&.first
        s.default = true
      end.save
    end
  end
end
