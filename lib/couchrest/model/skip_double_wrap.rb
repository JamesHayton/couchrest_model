# frozen_string_literal: true
#
# Guard: let Active Support build ONE wrapper per event.
#
module CouchRest
  module Model
    module SkipDoubleWrap
      def set_callback(name, *filter_list, &block)
        @_cr_seen_events ||= {}

        if @_cr_seen_events[name]
          # Wrapper already exists → just append the filters
          send(:_insert_callbacks, name, filter_list, &block)
        else
          @_cr_seen_events[name] = true
          super                           # first time → build wrapper
        end
      end
    end
  end
end
