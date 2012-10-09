
require 'model-state-objects/frozen-app-state'
require 'model-state-objects/ui-state'

module ModelStateObjects
  
  class AppState
    
    attr_accessor :machine, :ui_state
    
    def initialize(opts={})
      @machine = opts[:machine]
    end
    
    def method_missing(method, *args, &block)
      @ui_state.send(method, *args, &block)
    end
    
    def freeze(opts={})
      frozen_klass = opts[:klass] || FrozenAppState
      frozen_klass.new(:ui_state => @ui_state.class)
    end
    
  end
  
end
