# frozen_string_literal: true
#
# Guard: let Active Support build ONE wrapper for each event.
#
module CouchRest
  module Model
    module SkipDoubleWrap
      def set_callback(name, *filters, &block)
        @_cr_seen_events ||= {}
        if @_cr_seen_events[name]
          _insert_callbacks(name, filters, &block)   # just append filters
        else
          @_cr_seen_events[name] = true             # first time → build wrapper
          super
        end
      end
    end
  end
end
