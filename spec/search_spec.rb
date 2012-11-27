
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

describe 'ModelStateObjects::StateMachine' do
  let(:machine) do
    ModelStateObjects::StateMachine.new(:app_state_class => AppStateExample,
                                        :initial_ui_state_class => BasicState,
                                        :app_state_summary_class => AppStateSummaryExample)
  end
  let(:graph) { machine.search }
  let(:start_node_array) { graph.to_a.find { |k,v| k == machine.summarize } }
  let(:start_node) { start_node_array[0] }
  let(:start_edges) { start_node_array[1] }
  
  describe 'search' do
    it 'will look at neighbors of the starting node' do
      start_node.should_not == nil
      start_edges[:open_adder].ui_state_class.to_s.should == AddingLightbox.to_s
    end
  end
  describe 'search_table' do
    it 'can generate a search table' do
      machine.search_table
      rows = machine.search_table.find_all { |v1,e,v2| v1 == machine.summarize }
      rows.size.should == 1
      rows[0][1].should == :open_adder
      rows[0][2].ui_state_class.to_s.should == AddingLightbox.to_s
    end
  end
  describe 'walk' do
    it 'can generate a random walk' do
      walk = machine.random_walk(graph, machine.summarize, 10, (1..50).to_a)
      walk.map {|a,b,c| b}.should == [:open_adder, :add_string, :open_adder, :add_string, :open_adder, :cancel, :open_adder, :cancel, :open_adder, :cancel]
      walk.each do |v1, e, v2|
        machine.summarize.should == v1
        machine.send(e)
        machine.summarize.should == v2
      end
    end
    it 'can follow a random walk' do
      machine.walk!(machine.random_walk)
    end
  end
  
end
