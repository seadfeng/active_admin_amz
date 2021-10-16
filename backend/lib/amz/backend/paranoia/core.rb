
# require 'paranoia'
require 'amz/backend/paranoia/dsl'
require 'amz/backend/paranoia/authorization'
::ActiveAdmin::DSL.send(:include, Amz::Backend::Paranoia::DSL)