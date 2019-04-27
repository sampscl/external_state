defmodule PersistentlStateTest do
  use ExUnit.Case
  doctest ExternalState

  use ExternalState, persist: true, props: [a_var: :foo, other_var: :bar]

  test "stores persistent state" do
    default = %@ex_state_struct{}
    t = Task.async(fn ->
      # initialize the external state within this task
      init_ex_state()
      assert get_ex_state() == default
      assert put_ex_state(%{default| a_var: false}) == %{default| a_var: false}
      assert get_ex_state() == %{default| a_var: false}
    end)
    Task.await(t)

    # expect that the external state was remembered
    init_ex_state()
    assert get_ex_state() == %{default| a_var: false}
  end

end
