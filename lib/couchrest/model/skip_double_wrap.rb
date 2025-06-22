# frozen_string_literal: true
#
# Guard: let Active Support build ONE wrapper per event.
#
module CouchRest
  module Model
    module SkipDoubleWrap
      def set_callback(name, *filters, &block)
        @_cr_seen_events ||= {}
        if @_cr_seen_events[name]
          _insert_callbacks(name, filters, &block)  # just add filters
        else
          @_cr_seen_events[name] = true            # first time → wrap
          super
        end
      end
    end
  end
end

