# frozen_string_literal: true

module CouchRest #:nodoc:
  module Model #:nodoc:
    #
    # Active-Model style callbacks for CouchRest::Model.
    # (Legacy alias-method wrappers were removed for Rails 5+.)
    #
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

        # :initialize is unique to CouchRest
        define_model_callbacks :initialize, :only => :after

        # ------------------------------------------------------------
        # Define the CRUD events exactly once.
        # If another module has already defined *_callbacks we skip it,
        # preventing the second wrapper that caused the recursion.
        # ------------------------------------------------------------
        define_model_callbacks :save   unless respond_to? :_save_callbacks
        define_model_callbacks :create unless respond_to? :_create_callbacks
        define_model_callbacks :update unless respond_to? :_update_callbacks
        define_model_callbacks :destroy unless respond_to? :_destroy_callbacks
      end
  end
end



