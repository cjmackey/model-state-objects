
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

class AppStateSummaryExample < ModelStateObjects::AppStateSummary
  attr_accessor :str_count
  def initialize(app_state)
    super(app_state)
    self.str_count = app_state.strs.size
  end
  def <=>(x)
    super(x) == 0 ? self.str_count <=> x.str_count : super(x)
  end
end

class AppStateExample < ModelStateObjects::AppState
  attr_accessor :strs
  def initialize(*args)
    super(*args)
    self.strs = []
  end
end

describe AppStateExample do
  before :each do
    @machine = ModelStateObjects::StateMachine.new(:app_state_class => AppStateExample,
                                                   :initial_ui_state_class => BasicState,
                                                   :app_state_summary_class => AppStateSummaryExample)
  end
  
  it 'can transition by calling a method of the same name' do
    @machine.open_adder
    @machine.summarize.ui_state_class.to_s.should == AddingLightbox.to_s
    @machine.ui_state.is_a?(AddingLightbox).should == true
    @machine.cancel
    @machine.summarize.ui_state_class.to_s.should == BasicState.to_s
    @machine.ui_state.is_a?(BasicState).should == true
  end
  
  it 'will make changes, and verify them' do
    @machine.open_adder
    @machine.add_string
    @machine.summarize.str_count.should == 1
    @machine.strs.should == ['asdf']
  end
  
  it 'can chain methods representing multiple steps' do
    @machine.open_adder.add_string.open_adder.add_string('blah')
    @machine.summarize.str_count.should == 2
    @machine.strs.should == ['asdf', 'blah']
  end
  
  it 'can map out the graph of states' do
    graph = @machine.search
    graph.each do |vertex1, edges|
      edges.each do |step, vertex2|
        vertex1.str_count.should <= vertex2.str_count
        puts "#{vertex1.ui_state_class.to_s} #{vertex1.str_count} #{step} #{vertex2.ui_state_class.to_s} #{vertex2.str_count}"
      end
    end
  end
end
