
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'model-state-objects'

require 'rubygems'

require 'rspec'

class BasicState < ModelStateObjects::UIState
  def initialize(opts={})
    super(opts)
    def_transition :open_adder, AddingLightbox
  end
  def _open_adder
  end
end

class AddingLightbox < ModelStateObjects::UIState
  def initialize(opts={})
    super(opts)
    def_transition :cancel, BasicState
    def_transition :add_string, BasicState do |st|
      if st.respond_to? :str_count
        st.invalid! if st.str_count >= 2
        st.str_count += 1
      end
    end
  end
  def _cancel
  end
  def _add_string(str = 'asdf')
    app_state.strs << str
  end
end

class FrozenAppStateExample < ModelStateObjects::FrozenAppState
  attr_accessor :str_count
  def ==(x)
    super(x) && self.str_count == x.str_count
  end
end

class AppStateExample < ModelStateObjects::AppState
  attr_accessor :strs
  def initialize(*args)
    super(*args)
    self.ui_state = BasicState.new(:machine => @machine)
    self.strs = []
  end
  def freeze
    tmp = super(:klass => FrozenAppStateExample)
    tmp.str_count = self.strs.size
    tmp
  end
end

describe AppStateExample do
  before :each do
    @machine = ModelStateObjects::StateMachine.new(:initial_state => AppStateExample)
  end
  
  it 'can transition by calling a method of the same name' do
    @machine.open_adder
    @machine.freeze.ui_state.to_s.should == AddingLightbox.to_s
    @machine.cancel
    @machine.freeze.ui_state.to_s.should == BasicState.to_s
  end
  
  it 'will make changes, and verify them' do
    @machine.open_adder
    @machine.add_string
    @machine.freeze.str_count.should == 1
    @machine.strs.should == ['asdf']
  end
  
  it 'can chain methods representing multiple steps' do
    @machine.open_adder.add_string.open_adder.add_string('blah')
    @machine.freeze.str_count.should == 2
    @machine.strs.should == ['asdf', 'blah']
  end
  
  it 'can map out the graph of states' do
    machine = ModelStateObjects::StateMachine.new(:initial_state => AppStateExample)
    graph = machine.search
    graph.each do |vertex1, edges|
      edges.each do |step, vertex2|
        vertex1.str_count.should <= vertex2.str_count
        puts "#{vertex1.ui_state.to_s} #{vertex1.str_count} #{step} #{vertex2.ui_state.to_s} #{vertex2.str_count}"
      end
    end
  end
end
