# frozen_string_literal: true

module CouchRest #:nodoc:
  module Model #:nodoc:
    #
    # Provides Active-Model–style callbacks for CouchRest::Model. The only
    # change from the original implementation is a small guard that ensures
    # Active Support wraps each event (*save*, *create*, *update*, *destroy*)
    # **only once**.  Without that guard Rails 6/7 would prepend a second
    # wrapper the moment a second callback (e.g. `after_save`) is registered,
    # and the two wrappers would call each other forever on Ruby 3.2.
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

      # ---------------------------------------------------------------
      # Declare the callback events (unchanged from upstream code)
      # ---------------------------------------------------------------
      included do
        extend  ActiveModel::Callbacks
        include ActiveModel::Validations::Callbacks

        define_model_callbacks :initialize, :only => :after
        define_model_callbacks :create, :destroy, :save, :update
      end

      # ---------------------------------------------------------------
      # NEW: Guard Active Support’s internal `_update_hook` so the
      #       target method (e.g. `save`) is wrapped only *once*.
      #       Further `set_callback` calls merely append filters.
      # ---------------------------------------------------------------
      module NoDoubleWrap
        # event is :save, :create, :update, :destroy
        def _update_hook(event) # :nodoc:
          @_couchrest_wrapper_once ||= {}
          return if @_couchrest_wrapper_once[event]   # already wrapped → skip
          @_couchrest_wrapper_once[event] = true
          super                                       # first time → proceed
        end
      end

      # Prepend the guard to the singleton class of every model that
      # includes CouchRest::Model::Callbacks.
      def self.included(base)
        super
        base.singleton_class.prepend NoDoubleWrap
      end
    end
  end
end


