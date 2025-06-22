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

        # Event unique to CouchRest
        define_model_callbacks :initialize, :only => :after

        # Rails already defines :save/:create/:update; redefining them
        # would add a second wrapper and recurse forever.  We declare
        # :destroy only if it isn’t present.
        define_model_callbacks :destroy unless respond_to? :_destroy_callbacks
      end
    end
  end
end

# --------------------------------------------------------------------
# Add a guard **after** CouchRest::Model::Base is loaded so each event
# gets wrapped exactly once.
# --------------------------------------------------------------------
ActiveSupport.on_load(:couchrest_model_base) do
  module CouchRest::Model::SkipDoubleWrap
    def set_callback(name, *filters, &blk)
      @_cr_seen_events ||= {}
      if @_cr_seen_events[name]
        _insert_callbacks(name, filters, &blk) # just append
      else
        @_cr_seen_events[name] = true          # first time → wrap
        super
      end
    end
  end

  singleton_class.prepend CouchRest::Model::SkipDoubleWrap
end




