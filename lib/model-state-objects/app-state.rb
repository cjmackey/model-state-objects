
require 'model-state-objects/app-state-summary'
require 'model-state-objects/ui-state'

module ModelStateObjects
  
  class AppState
    
    attr_accessor :machine, :ui_state, :app_state_summary_class
    
    def initialize(opts={})
      @machine = opts[:machine]
      @ui_state = opts[:ui_state]
      @app_state_summary_class = opts[:app_state_summary_class]
    end
    
    def method_missing(method, *args, &block)
      @ui_state.send(method, *args, &block)
    end
    
    def summarize
      @app_state_summary_class.new(self)
    end
    
  end
  
end
