
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'model-state-objects'

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
    def_transition :some_adding_step, UIStateExample1 do |st|
      st.invalid! if st.blah >= 2
      st.blah += 1
    end
  end
  def _some_step
  end
  def _some_adding_step(str = 'asdf')
    app_state.blah << str
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
    #machine.transitions[:some_step].should_not == nil
    
    machine.some_step
    machine.freeze.ui_state.to_s.should == UIStateExample2.to_s
    #machine.transitions[:some_step].should_not == nil
    #machine.transitions[:some_other_step].should_not == nil
    
    machine.some_step
    machine.freeze.ui_state.to_s.should == UIStateExample1.to_s
    
    machine.some_step
    machine.freeze.ui_state.to_s.should == UIStateExample2.to_s
    
    machine.some_adding_step
    machine.freeze.ui_state.to_s.should == UIStateExample1.to_s
    machine.freeze.blah.should == 1
    machine.blah.should == ['asdf']
    
    machine.some_step
    machine.freeze.ui_state.to_s.should == UIStateExample2.to_s
    
    machine.some_adding_step('blah')
    machine.freeze.ui_state.to_s.should == UIStateExample1.to_s
    machine.freeze.blah.should == 2
    machine.blah.should == ['asdf', 'blah']
    
  end
  
  it 'can map out the graph of states' do
    machine = ModelStateObjects::StateMachine.new(:initial_state => AppStateExample)
    graph = machine.search
    graph.each do |vertex, edges|
      edges.each do |step, vertex2|
        vertex.blah.should <= vertex2.blah
        puts "#{vertex.ui_state.to_s} #{vertex.blah} #{step} #{vertex2.ui_state.to_s} #{vertex2.blah}"
      end
    end
  end
end
