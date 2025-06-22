# frozen_string_literal: true
#
# SkipDoubleWrap intercepts Active Support's set_callback so that each
# event (:save, :create, ...) is wrapped **once**.  Further callbacks on
# the same event just extend the filter chain; they do NOT alias another
# wrapper method, eliminating the alias loop on Ruby 3.x / Rails 7.x.
#
module CouchRest
  module Model
    module SkipDoubleWrap
      # name  = :save, :create, :update, :destroy, ...
      def set_callback(name, *filter_list, &block)
        @_cr_seen_events ||= {}

        if @_cr_seen_events[name]
          # Wrapper already exists → simply insert the new callbacks
          _insert_callbacks(name, filter_list, &block)
        else
          @_cr_seen_events[name] = true
          super                     # first time → let Rails build wrapper
        end
      end
    end
  end
end
