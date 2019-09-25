defmodule GeneralTest do
  use ExUnit.Case
  doctest ExternalState

  use ExternalState, persist: false, props: [a_var: :foo, other_var: :bar]

  test "merges maps" do
    init_ex_state()
    default = default_ex_state()
    merge_ex_state(%{a_var: false})
    # expect that the external state was remembered
    assert get_ex_state() == %{default| a_var: false}
  end

  test "merges kwl" do
    init_ex_state()
    default = default_ex_state()
    merge_ex_state(a_var: false)
    # expect that the external state was remembered
    assert get_ex_state() == %{default| a_var: false}
  end
end
