# frozen_string_literal: true

module CouchRest
  module Model
    module Callbacks
      extend ActiveSupport::Concern

      CALLBACKS = [
        :before_validation, :after_validation,
        :after_initialize,
        :before_create, :around_create, :after_create,
        :before_destroy, :around_destroy, :after_destroy,
        :before_save, :around_save, :after_save,
        :before_update, :around_update, :after_update
      ].freeze

      included do
        extend ActiveModel::Callbacks
        include ActiveModel::Validations::Callbacks

        # Define model callbacks
        define_model_callbacks :initialize, only: :after
        define_model_callbacks :save, :create, :update, :destroy
      end
      
      # Fix for Rails 7+ compatibility with CouchRest
      # The issue: When both before_save and after_save are defined on a CouchRest::Model::Base
      # subclass, Rails' DescendantsTracker gets into an infinite loop
      # 
      # Root cause: The complex inheritance chain in CouchRest combined with how Rails 7+
      # tracks descendants causes a circular reference during callback definition
      #
      # Solution: Use define_model_callbacks differently for save callbacks
      def self.included(base)
        super
        
        # Redefine save callbacks with a workaround for the Rails 7+ bug
        base.class_eval do
          # Remove the save callbacks defined by the included block
          if respond_to?(:_save_callbacks)
            reset_callbacks(:save)
          end
          
          # Define save callbacks in a way that avoids the DescendantsTracker bug
          # by separating the before and after chains
          define_model_callbacks :save, only: [:before, :around]
          define_model_callbacks :save_after, only: [:after]
          
          # Override after_save to use the separate callback chain
          class << self
            def after_save(*args, &block)
              set_callback(:save_after, :after, *args, &block)
            end
          end
          
          # Hook into save to run the after callbacks
          alias_method :_original_save_without_couchrest_fix, :save if method_defined?(:save)
          
          def save(*args)
            result = super
            if result
              run_callbacks(:save_after) { result }
            end
            result
          end
        end
      end
    end
  end
end