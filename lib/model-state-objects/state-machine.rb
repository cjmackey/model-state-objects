
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
    
    def search
      vertices = [self.freeze]
      edges = {}
      current_layer = vertices.clone
      while current_layer.size > 0
        next_layer = []
        current_layer.each do |vertex|
          edges[vertex] = {}
          vertex.ui_state.new.transitions(vertex).each do |trans_name, st|
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
    
  end
  
end
