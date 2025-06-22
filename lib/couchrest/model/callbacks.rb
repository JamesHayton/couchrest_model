# frozen_string_literal: true
require 'ostruct'

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

        # Define model callbacks - but NOT save callbacks due to Rails 7+ bug
        define_model_callbacks :initialize, only: :after
        define_model_callbacks :create, :update, :destroy
        
        # Manual callback system for save to avoid the bug
        class_attribute :_manual_save_callbacks, instance_writer: false, default: { before: [], around: [], after: [] }
        
        # Ensure callbacks are properly inherited
        def self.inherited(subclass)
          super
          subclass._manual_save_callbacks = _manual_save_callbacks.deep_dup
        end
      end
      
      module ClassMethods
        # Custom implementation that doesn't trigger DescendantsTracker bug
        def before_save(method_name = nil, &block)
          callback = method_name || block
          _manual_save_callbacks[:before] << callback
        end
        
        def around_save(method_name = nil, &block)
          callback = method_name || block
          _manual_save_callbacks[:around] << callback
        end
        
        def after_save(method_name = nil, &block)
          callback = method_name || block
          _manual_save_callbacks[:after] << callback
        end
        
        # For compatibility
        def _save_callbacks
          OpenStruct.new(map: _manual_save_callbacks.values.flatten)
        end
      end
      
      # Override save to run our manual callbacks
      def save(*args)
        # Run before callbacks
        self.class._manual_save_callbacks[:before].each do |callback|
          run_manual_callback(callback, :before)
        end
        
        # Run around callbacks (simplified - just wraps the save)
        result = nil
        if self.class._manual_save_callbacks[:around].empty?
          result = super(*args)
        else
          # For simplicity, just run around callbacks in sequence
          self.class._manual_save_callbacks[:around].each do |callback|
            result = run_manual_callback(callback, :around) { super(*args) }
          end
        end
        
        # Run after callbacks if save was successful
        if result
          self.class._manual_save_callbacks[:after].each do |callback|
            run_manual_callback(callback, :after)
          end
        end
        
        result
      end
      
      private
      
      def run_manual_callback(callback, type, &block)
        if callback.is_a?(Symbol)
          if block_given?
            send(callback, &block)
          else
            send(callback)
          end
        elsif callback.is_a?(Proc)
          if block_given?
            instance_exec(&block)
          else
            instance_exec(&callback)
          end
        elsif callback.is_a?(Class) || callback.is_a?(Module)
          # Handle class-based callbacks (like Sales::PaymentLinkCallbacks)
          method_name = type == :before ? :before_save : :after_save
          if callback.respond_to?(method_name)
            callback.send(method_name, self)
          end
        end
      end
      
      def save!(*args)
        save(*args) || raise(CouchRest::Model::Errors::Validations.new(self))
      end
    end
  end
end