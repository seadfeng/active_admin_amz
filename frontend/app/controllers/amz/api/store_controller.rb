module Amz
    module Api
        class StoreController < Amz::Api::BaseController
            before_action :load_data, only: :show

            def index 
                render  json: Store.all.map{|x| {id: x.id, name: x.name, domain: x.domain, url: x.url }}  
            end

            def show 
                render  json: {id: @store.id, name: @store.name, domain: @store.domain , url: @store.url }
            end

            private

            def load_data
                @store = Store.find(params[:id])
            end

        end
    end
end