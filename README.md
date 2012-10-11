model-state-objects
===================

An experimental sort-of framework intended to be used for building
model-based UI tests.

The basic concept is that UI states are abstractions of where a user
might be in the UI, while the App state includes more detailed
hidden data. For example, in a web app with different account types,
there would be UI states for, say, the log-in page and an account
page, while the App state would contain information on the user's
account level and whether ze is logged in or not.

In order to simplify app state for analysis, it has a `#summarize`
method which produces an app state summary.  This serves two purposes:

1. Multiple real app states can be condensed into a few app state
summaries by throwing away information.  This helps combat state space
explosion.

2. Transitions, which are defined at the UI state level, define what
will happen to the summaries. This makes the state machine
deterministic, and makes it possible to simulate the state machine.

By looking at the initial App state (which contains the UI state), and
taking transitions a-la breadth-first-search or depth-first-search, we
can map out all the possible App state summaries, assuming they are
finite.

Usage
=====

`spec/example_spec.rb` is an example

When using this library, one must define the UI states, an `AppState`,
and the `AppStateSummary`.

UIState
-------

For each UI state your app has, define a class inheriting from
`ModelStateObjects::UIState`.  In its `initialize` method, define
transitions with `def_transition`, and make sure that the class has a
method of the same name with a prepended underscore--this method will
be the transition's implementation.

```ruby
class SomeState < ModelStateObjects::UIState
  def initialize(*args)
    super(*args)
    def_transition :some_transition, SomeOtherState
  end
  def _some_transition
    # The ui automation to click on buttons or fill out fields would
    # go here.
  end
end
```

If the transition would cause a state change other than simply moving
from one UI state to another, `def_transition` can take a block which
manipulates an App state summary, representing what changes should
take place.

```ruby
def_transition :submit_comment, DoneSubmitting do |st|
  st.comment_count += 1
end
```

AppState and AppStateSummary
----------------------------

I'm still thinking this could be changed in the future. At the moment,
they are expected to inherit from ModelStateObjects::AppState and
ModelStateObjects::AppStateSummary, and may need to reimplement
#summarize and #==.



