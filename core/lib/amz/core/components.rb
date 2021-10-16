module Amz
    module Core
      class Engine < ::Rails::Engine  
        def self.backend_available?
          @@backend_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?('Amz::Backend::Engine')
        end
  
        def self.frontend_available?
          @@frontend_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?('Amz::Frontend::Engine')
        end
      end
    end
  end