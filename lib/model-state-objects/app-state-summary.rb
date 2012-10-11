
module ModelStateObjects
  
  class AppStateSummary
    
    attr_accessor :ui_state_class
    
    def initialize(opts={})
      @ui_state_class = opts[:ui_state_class]
      @valid = true
    end
    
    def ==(x)
      return false unless x.kind_of? AppStateSummary
      self.ui_state_class.to_s == x.ui_state_class.to_s
    end
    
    def valid?
      @valid
    end
    def invalid!
      @valid = false
    end
    
  end
  
end
