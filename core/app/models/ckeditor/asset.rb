class Ckeditor::Asset < ActiveRecord::Base
    if defined?(Ckeditor::Orm)
        include Ckeditor::Orm::ActiveRecord::AssetBase
        include Ckeditor::ActiveStorage
    
        attr_accessor :data
    
        has_one_attached :storage_data
    end
end