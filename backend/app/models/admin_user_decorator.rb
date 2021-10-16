class AdminUserDecorator
    if defined?(AdminUser)
        AdminUser.class_eval do 
            validates :first_name, presence: true
            validates :last_name, presence: true
            has_one  :image, as: :viewable, dependent: :destroy, class_name: 'Image', autosave: true
            has_many :articles,-> { order("#{Article.quoted_table_name}.published_at desc") }, class_name: 'Amz::Article', foreign_key: 'user_id'
            has_rich_text :content
            
            def find_or_build_image
                image || build_image
            end  
        
            def attachment=(_attachment)  
                unless _attachment.blank?
                    image = find_or_build_image 
                    image.attachment.attach( _attachment )
                end
            end

            def content=(_content)  
                unless _content.blank? 
                    content = build_rich_text_content if content.nil?
                    content.body = _content
                    content.save
                end
            end


            def full_name
                "#{first_name} #{last_name}"
            end

            def display_name
                "#{self.full_name} - #{role}"
            end 
        end 
    end
end