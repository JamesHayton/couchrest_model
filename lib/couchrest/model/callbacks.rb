# encoding: utf-8
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
      ]

      # ------------------------------------------------------------------
      # Declare the events – this part was already in the file
      # ------------------------------------------------------------------
      included do
        extend  ActiveModel::Callbacks
        include ActiveModel::Validations::Callbacks

        define_model_callbacks :initialize, :only => :after
        define_model_callbacks :create, :destroy, :save, :update
      end

      # ------------------------------------------------------------------
      # NEW: single prepend-based wrapper (Rails-5+ idiom)
      # ------------------------------------------------------------------
      module PrependWrapper
        def save(*a, **k, &b)    = run_callbacks(:save)    { super }
        def create(*a, **k, &b)  = run_callbacks(:create)  { super }
        def update(*a, **k, &b)  = run_callbacks(:update)  { super }
        def destroy(*a, **k, &b) = run_callbacks(:destroy) { super }
      end

      # ActiveSupport::Concern already defines .included;
      # we extend it and then prepend our wrapper exactly once.
      def self.included(base)
        super
        base.prepend PrependWrapper
      end
    end
  end
end

