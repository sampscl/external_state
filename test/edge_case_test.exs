defmodule EdgeCaseTest do
  use ExUnit.Case
  doctest ExternalState

    use ExternalState, persist: false, props: [a_var: :foo, other_var: :bar]

    test "fails in predictable ways" do
      assert nil == get_ex_state()
      assert nil == put_ex_state(%{default_ex_state()| a_var: false})
    end

end
