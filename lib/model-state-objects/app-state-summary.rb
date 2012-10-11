
module ModelStateObjects
  
  class AppStateSummary
    
    attr_accessor :ui_state
    
    def initialize(opts={})
      @ui_state = opts[:ui_state]
      @valid = true
    end
    
    def ==(x)
      return false unless x.kind_of? AppStateSummary
      self.ui_state.to_s == x.ui_state.to_s
    end
    
    def valid?
      @valid
    end
    def invalid!
      @valid = false
    end
    
  end
  
end
