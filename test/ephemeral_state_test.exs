defmodule EphemeralStateTest do
  use ExUnit.Case
  doctest ExternalState

    use ExternalState, persist: false, props: [a_var: :foo, other_var: :bar]

    test "stores ephemeral state" do
      default = %@ex_state_struct{}
      t = Task.async(fn ->
        # initialize the external state within this task
        assert get_ex_state() == default
        assert put_ex_state(%{default| a_var: false}) == %{default| a_var: false}
        assert get_ex_state() == %{default| a_var: false}
      end)
      Task.await(t)

      # expect that the external state was forgotten and reset to default when
      # the task exited
      assert get_ex_state() == default
    end

end
