module ActiveStorage
    module ImageStorage
      extend ActiveSupport::Concern
  
      included do
        include Rails.application.routes.url_helpers
        validate :check_attachment_presence
        validate :check_attachment_content_type
  
        has_one_attached :attachment
        after_commit :save_dimensions_now
  
        def self.styles
          @styles ||= {
            mini:    '48x48>',
            small:   '100x100>',
            product: '240x240>',
            medium: '430x430>',
            large:   '768x768>',
            wide:   '1600x1600>',
            widex2:   '2560x2560>',
          }
        end
  
        def default_style
          :product
        end
  
        def accepted_image_types
            %w(image/jpeg image/jpg image/png image/gif image/svg+xml image/webp)
        end
  
        def check_attachment_presence 
          unless attachment.attached? 
            # attachment.purge
            errors.add(:attachment, :attachment_must_be_present)
          end
        end
  
        def check_attachment_content_type 
          if attachment.attached? && !attachment.content_type.in?(accepted_image_types)
            # attachment.persisted? && attachment.purge 
            errors.add(:attachment, :not_allowed_content_type)
          end
        end
  
        def url(style)
          return placeholder(style) unless attachment.attached?
          if attachment.content_type == "image/svg+xml" 
            rails_blob_path( attachment, only_path: true)
          else 
            attachment.variant(resize: dimensions_for_style(style))
          end
        end 

        def resize(size)
          return placeholder('mini') unless attachment.attached?
          attachment.variant(resize: size)
        end  
  
        def placeholder(style)
          "amz/noimage/#{style}.png"
        end
  
        def dimensions_for_style(style)
          self.class.styles.with_indifferent_access[style] || default_style
        end 

        def height
          attachment.metadata['height']
        end
      
        def width
          attachment.metadata['width']
        end

        def analyzed? 
          attachment.analyzed?
        end
 
        def box(style) 
          if attachment.analyzed?
            sizes = dimensions_for_style(style).sub(/>/,'').split('x').map{ |x| x.to_f }
            scale = sizes[0] / sizes[1]
            attachment_scale =  width.to_f  /  height.to_f
            box = { } 
            if(attachment_scale == scale)
              box[:width] = sizes[0] 
              box[:height] = sizes[1]  
            else
              if( sizes[0] / width > sizes[1] / height  )
                box[:height] = sizes[1] 
                box[:width] = (sizes[1] / height) * width
              else 
                box[:width] = sizes[0] 
                box[:height] = (sizes[0] / width) * height
              end 
            end 
            box[:width] = box[:width].round() 
            box[:height] = box[:height].round() 
            box
          end
        end

        def analyze
          attachment.analyze
        end
      
        private

        def save_dimensions_now
          attachment.analyze_later if attachment.attached?
        end
  
      end
  
    end
  end
  