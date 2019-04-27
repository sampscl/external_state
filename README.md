# ExternalState

Store state, as a properties structure, externally to a process.

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

- ```@ex_state_struct``` An atom name for your external state structure
- ```default_ex_state/0``` Get a state structure with default values from props
- ```init_ex_state/0``` Initialize your external state; must call once
- ```get_ex_state/0``` Get the current external state
- ```put_ex_state/1``` Set the external state
- ```merge_ex_state/1``` Update the external state with values from the
  parameter, which can be a keyword list or a map.

If ExternalState is `use`d with persist: true, then the external state will
remain valid after the process that calls `init_ex_state/0` exits. This
is the default.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `external_state` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:external_state, "~> 1.0.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/external_state](https://hexdocs.pm/external_state).
