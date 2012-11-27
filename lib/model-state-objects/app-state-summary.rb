
module ModelStateObjects
  
  class AppStateSummary
    
    attr_accessor :ui_state_class
    
    def initialize(app_state)
      @ui_state_class = app_state.ui_state.class
      @valid = true
    end
    
    def ==(x)
      return false unless x.kind_of? AppStateSummary
      (self <=> x) == 0
    end
    def ===(x)
      self == x
    end
    
    def <=>(x)
      raise ArgumentError "#{x} is not a kind of AppStateSummary!" unless x.kind_of? AppStateSummary
      self.ui_state_class.to_s <=> x.ui_state_class.to_s
    end
    
    def valid?
      @valid
    end
    
    def invalid!
      @valid = false
    end
    
  end
  
end
