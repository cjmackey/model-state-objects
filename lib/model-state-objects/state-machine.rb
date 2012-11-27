
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
    
    def search(start=nil)
      start ||= self.summarize
      vertices = [start]
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
    
    def search_table(graph=nil)
      return graph if graph.kind_of? Array # was given a search_table already
      graph ||= self.search
      table = []
      graph.each do |vertex1, edges|
        edges.each do |step, vertex2|
          table << [vertex1, step, vertex2]
        end
      end
      table.map { |v1, e, v2| [v1, e.to_s, v2] }.sort.map { |v1, e, v2| [v1, e.to_sym, v2] }
    end
    
    def random_walk(graph=nil, start=nil, maxlength = 20, randlist=nil)
      table = search_table(graph)
      start ||= self.summarize
      randlist ||= []
      randlist = randlist.reverse
      output = []
      current_row = [nil,nil,start]
      
      while maxlength && output.size < maxlength
        potential_rows = table.find_all do |v1,e,v2|
          current_row[2] == v1
        end
        return output if potential_rows.size == 0
        current_row = potential_rows[(randlist.pop || rand(potential_rows.size)) % potential_rows.size]
        output << current_row
      end
      output
    end
    
    def random_walk!(*args)
      walk!(random_walk(*args))
    end
    
    def walk!(walk)
      walk.each do |v1, e, v2|
        self.summarize.should == v1
        self.machine.send(e)
        self.machine.summarize.should == v2
      end
    end
    
    def logger
      @logger ||= Logger.new STDOUT
    end
    
  end
  
end
