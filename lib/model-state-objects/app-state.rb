
require 'model-state-objects/app-state-summary'
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
    
    def summarize(opts={})
      klass = opts[:klass] || AppStateSummary
      klass.new(:ui_state => @ui_state.class)
    end
    
  end
  
end
