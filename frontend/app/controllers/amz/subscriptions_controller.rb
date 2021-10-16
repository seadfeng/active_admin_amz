module Amz
    class SubscriptionsController < Amz::StoreController
        def new

        end

        def cancel
            subscription = Amz::Subscription.find_by(unsubscribe_token: params[:token])
            block = current_store.blocks.published.find_by(identity: 'unsubscription')
            if subscription.present?
                user = subscription.user
                if user.present?
                    user.subscription = false
                    user.save
                else
                    subscription.unsubscribe! 
                end
                if block.present?
                    @description = block.description
                end
            else
                route_not_found
            end
        end
    end
end
