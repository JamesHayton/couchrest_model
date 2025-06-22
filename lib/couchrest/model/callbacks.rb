# frozen_string_literal: true

module CouchRest #:nodoc:
  module Model #:nodoc:
    #
    # Active-Model style callbacks for CouchRest::Model.
    # Legacy alias-method-chain wrappers have been removed; Rails’
    # modern prepend wrapper handles all events.
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

        # Event unique to CouchRest
        define_model_callbacks :initialize, :only => :after

        # Rails (via ActiveModel::Validations::Callbacks) already
        # defines :save, :create and :update — redefining them would
        # add a second wrapper and cause infinite recursion.
        #
        # We define :destroy **only if** it is still missing.
        define_model_callbacks :destroy unless respond_to? :_destroy_callbacks
      end
    end
  end
end

# --------------------------------------------------------------------
# Prevent a second wrapper from being generated for the *same* event.
# --------------------------------------------------------------------
require_relative "skip_double_wrap"   # see file below

CouchRest::Model::Base.singleton_class.prepend(
  CouchRest::Model::SkipDoubleWrap
)




