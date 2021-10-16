# Make redirects for SEO needs
module Amz
    module Frontend
      module Middleware
        class SeoAssist
          def initialize(app)
            @app = app
          end
  
          def call(env)
            # request = Rack::Request.new(env)
            # params = request.params
  
            # review_id = params['review_id']
  
            # # redirect requests using review id's to their permalinks
            # if !review_id.blank? && !review_id.is_a?(Hash) && category = Amz::Review.find(review_id)
            #   params.delete('review_id')
  
            #   return build_response(params, "#{request.script_name}#{review.slug}")
            # elsif env['PATH_INFO'] =~ /^\/(categories|results)(\/\S+)?\/$/
            #   # ensures no trailing / for taxon and product urls
  
            #   return build_response(params, env['PATH_INFO'][0...-1])
            # end
  
            @app.call(env)
          end
  
          private
  
          def build_response(params, location)
            query = build_query(params)
            location += '?' + query unless query.blank?
            [301, { 'Location' => location }, []]
          end
  
          def build_query(params)
            params.map do |k, v|
              if v.class == Array
                build_query(v.map { |x| ["#{k}[]", x] })
              else
                k + '=' + Rack::Utils.escape(v)
              end
            end.join('&')
          end
        end
      end
    end
  end