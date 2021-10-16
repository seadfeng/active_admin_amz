require 'cancancan'
module Amz
    class Ability
      include CanCan::Ability
  
      class_attribute :abilities
      self.abilities = Set.new
  
      # Allows us to go beyond the standard cancan initialize method which makes it difficult for engines to
      # modify the default +Ability+ of an application.  The +ability+ argument must be a class that includes
      # the +CanCan::Ability+ module.  The registered ability should behave properly as a stand-alone class
      # and therefore should be easy to test in isolation.
      def self.register_ability(ability)
        abilities.add(ability)
      end
  
      def self.remove_ability(ability)
        abilities.delete(ability)
      end
  
      def initialize(user) 
        # add cancancan aliasing
        alias_action :delete, to: :destroy
        alias_action :create, :update, :destroy, to: :modify
  
        user ||= Amz.user_class.new
        
        can [:show, :update, :destroy, :profile], Amz.user_class, id: user.id  
  
        # Include any abilities registered by extensions, etc.
        Ability.abilities.merge(abilities_to_register).each do |clazz|
          merge clazz.new(user)
        end 
      end
  
      private
  
      # you can override this method to register your abilities
      # this method has to return array of classes
      def abilities_to_register
        []
      end
    end
  end
