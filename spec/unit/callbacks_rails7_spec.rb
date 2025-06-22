require 'spec_helper'

describe "Rails 7+ Callback Compatibility" do
  class TestCallbackClass
    def self.before_save(model)
      # Simulate callback behavior
    end
    
    def self.after_save(model)
      # Simulate callback behavior
    end
  end
  
  class ModelWithTwoCallbacks < CouchRest::Model::Base
    property :name, String
    
    before_save TestCallbackClass
    after_save TestCallbackClass
  end
  
  it "should not cause stack overflow with multiple callbacks" do
    model = ModelWithTwoCallbacks.new(name: "Test")
    expect { model.save }.not_to raise_error
  end
  
  it "should properly execute callbacks in order" do
    call_order = []
    
    class CallbackTracker
      def self.call_order=(val)
        @call_order = val
      end
      
      def self.call_order
        @call_order
      end
      
      def self.before_save(model)
        @call_order << :before
      end
      
      def self.after_save(model)
        @call_order << :after
      end
    end
    
    class ModelWithOrderedCallbacks < CouchRest::Model::Base
      property :name, String
      
      before_save CallbackTracker
      after_save CallbackTracker
    end
    
    CallbackTracker.call_order = call_order
    model = ModelWithOrderedCallbacks.new(name: "Test")
    model.save
    
    expect(call_order).to eq([:before, :after])
  end
end