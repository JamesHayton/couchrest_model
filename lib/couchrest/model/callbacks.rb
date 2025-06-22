# frozen_string_literal: true

module CouchRest #:nodoc:
  module Model #:nodoc:
    module Callbacks
      extend ActiveSupport::Concern

      CALLBACKS = %i[
        before_validation after_validation
        after_initialize
        before_create around_create after_create
        before_destroy around_destroy after_destroy
        before_save   around_save   after_save
        before_update around_update after_update
      ].freeze

      included do
        extend  ActiveModel::Callbacks
        include ActiveModel::Validations::Callbacks

        # Event unique to CouchRest
        define_model_callbacks :initialize, :only => :after

        # Define the four CRUD events.  SkipDoubleWrap (see below)
        # ensures each one is wrapped at most once.
        define_model_callbacks :save, :create, :update, :destroy
      end
    end
  end
end

require_relative "skip_double_wrap"

ActiveSupport.on_load(:couchrest_model_base) do
  singleton_class.prepend CouchRest::Model::SkipDoubleWrap
end







