
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
      @transition_times = {}
    end
    
    # override this with whatever checks are desired. this will be
    # called after this state is transitioned to.
    def on_entry
    end
    
    # override this with whatever checks are desired. this will be
    # called after this state is transitioned from.
    def on_exit
    end
    
    # takes a transition name and a block.  the block takes a frozen
    # copy of the current AppState (in the form of FrozenAppState),
    # and creates a new FrozenAppState, which will be checked against
    # the next state after the transition is called.  the UIState
    # subclass should implement a method named the same name but with
    # a leading underscore.  optionally, one can provide a time
    # estimate, in seconds, for how long the transition will take on
    # average.
    def def_transition(name, next_ui_state_class=nil, transition_time=1.0, &block)
      raise ArgumentError, 'Transition names must be symbols!' unless name.is_a? Symbol
      @transition_names << name
      @transition_blocks[name] = block
      @transition_next_states[name] = next_ui_state_class
      @transition_times[name] = transition_time
    end
    
    def transitions(current_state=nil)
      trans_hash = {}
      @transition_names.each do |name|
        next_state = estimate_next_app_state(name, current_state)
        trans_hash[name] = next_state if next_state.valid?
      end
      trans_hash
    end
    
    def estimate_next_app_state(method, current_state_summary=nil)
      next_app_state_summary = (current_state_summary || app_state.summarize).clone
      if @transition_next_states[method]
        next_app_state_summary.ui_state_class = @transition_next_states[method]
      end
      if @transition_blocks[method]
        @transition_blocks[method].call(next_app_state_summary)
      end
      next_app_state_summary
    end
    
    def transition(method, *args, &block)
      
      sub_method = "_#{method}".to_sym
      unless self.respond_to? sub_method
        raise NoMethodError, "sub_method #{self.class}##{sub_method} does not exist"
      end
      
      expected_next_app_state = estimate_next_app_state(method)
      unless expected_next_app_state.valid?
        raise ArgumentError, "transition #{method} is invalid from this state (#{self.class})!"
      end
      
      logger.debug("transitioning from #{self.class} using ##{method} " +
                   "to #{expected_next_app_state.ui_state_class}")
      
      self.send(sub_method, *args, &block)
      
      on_exit
      
      app_state.ui_state = expected_next_app_state.ui_state_class.new(:machine => self.machine)
      app_state.ui_state.on_entry
      app_state.summarize.should == expected_next_app_state
      
      machine
    end
    
    def app_state
      machine.app_state
    end
    def logger
      machine.logger
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
