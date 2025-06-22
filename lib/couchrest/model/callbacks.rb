# frozen_string_literal: true

module CouchRest #:nodoc:
  module Model #:nodoc:
    #
    # Active-Model style callbacks for CouchRest::Model.
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

        # CouchRest-specific event
        define_model_callbacks :initialize, :only => :after

        # Rails already defines :save, :create, :update via
        # ActiveModel::Validations::Callbacks.  Declaring them again
        # would add a second wrapper and recurse forever.
        #
        # We add :destroy only if it isn’t present.
        define_model_callbacks :destroy unless respond_to? :_destroy_callbacks
      end
    end
  end
end

# ------------------------------------------------------------------
# After CouchRest::Model::Base is loaded, prepend the guard that keeps
# each event wrapped exactly once.
# ------------------------------------------------------------------
require_relative "skip_double_wrap"

ActiveSupport.on_load(:couchrest_model_base) do
  singleton_class.prepend CouchRest::Model::SkipDoubleWrap
end






