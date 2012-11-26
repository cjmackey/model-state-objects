
require 'model-state-objects/app-state'

module ModelStateObjects
  
  class StateMachine
    
    attr_accessor :app_state
    
    def initialize(opts={})
      ui_state = opts[:initial_ui_state_class].new(:machine => self)
      @app_state = opts[:app_state_class].new(:machine => self,
                                              :ui_state => ui_state,
                                              :app_state_summary_class => opts[:app_state_summary_class])
      raise ArgumentError unless @app_state.kind_of? AppState
      @logger = opts[:logger]
    end
    
    def method_missing(method, *args, &block)
      @app_state.send(method, *args, &block)
    end
    
    def search
      vertices = [self.summarize]
      edges = {}
      current_layer = vertices.clone
      while current_layer.size > 0
        next_layer = []
        current_layer.each do |vertex|
          edges[vertex] = {}
          vertex.ui_state_class.new.transitions(vertex).each do |trans_name, st|
            edges[vertex][trans_name] = st
            found = false
            vertices.each do |v|
              found ||= (v == st)
            end
            unless found
              next_layer << st
              vertices << st
            end
          end
        end
        current_layer = next_layer
      end
      edges
    end
    
    def logger
      @logger ||= Logger.new STDOUT
    end
    
  end
  
end
