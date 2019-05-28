# ExternalState

Store state, as a properties structure, externally to a process.

## Motivation

A process in Elixir stores data in its state that other processes may need -- a
current status flag for instance. The standard way of sharing this data is to
provide an API that results in a GenServer call. But, what if the GenServer
is busy working on a long-running job? You could break your long running jobs
into pieces and allow the GenServer to check its message queue. Yuck,
cooperative multitasking and added complexity. You could create an ETS table or
other external database record. Yuck, verbose, complex, and high-friction solution
to what should be a simple problem.

ExternalState helps solve this problem by providing a clean way of stashing
some or all of your state in a data structure managed by a different process.

Caveat lector: this works beautifully for named workers but doesn't work well
with simple 1-for-1 workers because the state is managed using the module name.

## Usage
```elixir
defmodule MyGenserver do
  use ExternalState, persist: false, props: [foo: true]

  def init(:ok) do
    init_ex_state() # external state is now at the defaults specified in use
  end

  # ...

  def do_foo do
    # ... something that sets foo to true ...
    merge_ex_state(foo: true)
  end

  def undo_foo do
    # ... something that sets foo to false ...
    merge_ex_state(foo: false)
    # or: merge_ex_state(%{foo: false})
  end

  def foo? do
    get_ex_state().foo
  end

end
```

## API
The following are added to your module when you `use` ExternalState:

- `@ex_state_struct` An atom name for your external state structure
- `default_ex_state/0` Get a state structure with default values from props
- `init_ex_state/0` Initialize your external state; must call once, multiple calls are okay
- `get_ex_state/0` Get the current external state or nil if no init yet
- `put_ex_state/1` Set the external state, returns the state or nil if no init yet
- `merge_ex_state/1` Update the external state with values from the
  parameter, which can be a keyword list of keys and values or a map. Returns
  the updated state or nil if no init yet.

If ExternalState is `use`d with `persist: true`, then the external state will
remain valid after the process that calls `init_ex_state/0` exits. This
is the default.

## Installation

The package can be installed by adding `external_state` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:external_state, "~> 1.0.5"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/external_state](https://hexdocs.pm/external_state).
