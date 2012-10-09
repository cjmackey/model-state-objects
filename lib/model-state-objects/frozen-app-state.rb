
require 'rubygems'

module ModelStateObjects
  
  class FrozenAppState
    
    attr_accessor :ui_state
    
    def initialize(opts={})
      @ui_state = opts[:ui_state]
    end
    
    def ==(x)
      return false unless x.kind_of? FrozenAppState
      self.ui_state.to_s == x.ui_state.to_s
    end
    
  end
  
end