
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'state-machine'

require 'rubygems'

require 'rspec'

class UIStateExample1 < ModelStateObjects::UIState
  def initialize(opts={})
    super(opts)
    def_transition :some_step, UIStateExample2
  end
  def _some_step
  end
end

class UIStateExample2 < ModelStateObjects::UIState
  def initialize(opts={})
    super(opts)
    def_transition :some_step, UIStateExample1
    def_transition :some_other_step, UIStateExample1 do |st|
      st.blah += 1
    end
  end
  def _some_step
  end
  def _some_other_step
    app_state.blah ||= []
    app_state.blah << 'asdf'
  end
end

class FrozenAppStateExample < ModelStateObjects::FrozenAppState
  attr_accessor :blah
  def ==(x)
    super(x) && self.blah == x.blah
  end
end

class AppStateExample < ModelStateObjects::AppState
  attr_accessor :blah
  def initialize(*args)
    super(*args)
    self.ui_state = UIStateExample1.new(:machine => @machine)
    self.blah = []
  end
  def freeze
    tmp = super(:klass => FrozenAppStateExample)
    tmp.blah = self.blah.size
    tmp
  end
end

describe 'blah' do
  it 'runs through this example' do
    machine = ModelStateObjects::StateMachine.new(:initial_state => AppStateExample)
    machine.some_step
    machine.freeze.ui_state.to_s.should == UIStateExample2.to_s
    
    machine.some_step
    machine.freeze.ui_state.to_s.should == UIStateExample1.to_s
    
    machine.some_step
    machine.freeze.ui_state.to_s.should == UIStateExample2.to_s
    
    machine.some_other_step
    machine.freeze.ui_state.to_s.should == UIStateExample1.to_s
    machine.freeze.blah.should == 1
    machine.blah.should == ['asdf']
  end
end
