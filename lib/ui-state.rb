
require 'rubygems'

require 'set'

module ModelStateObjects
  
  class UIState
    
    attr_accessor :machine
    
    def initialize(opts={})
      @machine = opts[:machine]
      @transition_names = Set.new()
      @transition_blocks = {}
      @transition_next_states = {}
    end
    
    # takes a transition name and a block.  the block takes a frozen
    # copy of the current AppState (in the form of FrozenAppState),
    # and creates a new FrozenAppState, which will be checked against
    # the next state after the transition is called.  the UIState
    # subclass should implement a method named the same name but with
    # a leading underscore.
    def def_transition(name, next_ui_state_class=nil, &block)
      name = name.to_sym
      @transition_names << name
      @transition_blocks[name] = block
      @transition_next_states[name] = next_ui_state_class
    end
    
    def transition(method, *args, &block)
      
      next_app_state = app_state.freeze
      if @transition_blocks[method]
        @transition_blocks[method].call(next_app_state)
      end
      if @transition_next_states[method]
        next_app_state.ui_state = @transition_next_states[method]
      end
      
      sub_method = "_#{method}".to_sym
      raise NoMethodError, "sub_method #{sub_method} does not exist" unless self.respond_to? sub_method
      self.send(sub_method, *args, &block)
      
      app_state.ui_state = next_app_state.ui_state.new(:machine => self.machine)
      app_state.freeze.should == next_app_state
      
      machine
    end
    
    def app_state
      machine.app_state
    end
    
    def method_missing(method, *args, &block)
      if @transition_names.include?(method)
        transition(method, *args, &block)
      else
        raise NoMethodError, "no such transition: #{method.inspect}"
      end
    end
    
  end
  
end
