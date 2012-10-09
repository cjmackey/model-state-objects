
require 'model-state-objects/app-state'

module ModelStateObjects
  
  class StateMachine
    
    attr_accessor :app_state
    
    def initialize(opts={})
      @app_state ||= opts[:initial_state].new(:machine => self)
      raise ArgumentError unless @app_state.kind_of? AppState
    end
    
    def method_missing(method, *args, &block)
      @app_state.send(method, *args, &block)
    end
    
    def freeze
      @app_state.freeze
    end
    
  end
  
end
