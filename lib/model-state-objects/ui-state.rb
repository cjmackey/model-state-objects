
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
    
    # override this with whatever checks are desired. this will be
    # called whenever this state is transitioned to.
    def on_entry
    end
    
    # override this with whatever checks are desired. this will be
    # called whenever this state is transitioned from.
    def on_exit
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
    
    def transitions(current_state=nil)
      trans_hash = {}
      @transition_names.each do |name|
        trans_hash[name] = estimate_next_app_state(name, current_state)
      end
      trans_hash
    end
    
    def estimate_next_app_state(method, current_state=nil)
      next_app_state = (current_state || app_state.freeze).clone
      if @transition_blocks[method]
        @transition_blocks[method].call(next_app_state)
      end
      if @transition_next_states[method]
        next_app_state.ui_state = @transition_next_states[method]
      end
      next_app_state
    end
    
    def transition(method, *args, &block)
      on_exit
      
      expected_next_app_state = estimate_next_app_state(method)
      
      sub_method = "_#{method}".to_sym
      raise NoMethodError, "sub_method #{sub_method} does not exist" unless self.respond_to? sub_method
      self.send(sub_method, *args, &block)
      
      app_state.ui_state = expected_next_app_state.ui_state.new(:machine => self.machine)
      app_state.ui_state.on_entry
      app_state.freeze.should == expected_next_app_state
      
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
