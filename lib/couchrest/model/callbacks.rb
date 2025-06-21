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

        define_model_callbacks :initialize, :only => :after

        # Rails (via ActiveModel::Validations::Callbacks) already defines
        # :save, :create and :update.  We only need to *add* :destroy –
        # and even that only if it isn’t there yet.
        define_model_callbacks :destroy unless respond_to?(:_destroy_callbacks)
      end
    end
  end
end



