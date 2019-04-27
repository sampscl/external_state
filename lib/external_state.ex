defmodule ExternalState do
  @moduledoc """
  Support storing all or part of some state externally to the owning pid(s).
  Builds on ETS.
  """
  defmacro __using__(kwl) do

    persist = Keyword.get(kwl, :persist, true)
    props = Keyword.get(kwl, :props, [])

    struct = quote do
      struct_mod = String.to_atom("#{__MODULE__}.ExternalState")
      @external_state_persist unquote(persist)
      defmodule struct_mod do
        defstruct unquote(props)
      end
    end

    funcs = quote do
      @ex_state_struct String.to_atom("#{__MODULE__}.ExternalState")

      def init_ex_state do
        case @external_state_persist do
          true ->
            EtsOwner.create_table(@ex_state_struct, :set)

          false ->
            try do
              if :ets.info(@ex_state_struct) == :undefined do
                :ets.new(@ex_state_struct, [:public, :named_table, :set])
              end
            rescue _ -> :ok
            end
        end
      end

      def get_ex_state do
        init_ex_state()
        case :ets.lookup(@ex_state_struct, :state) do
          [{:state, result}] ->
            result

          _ ->
          result = %@ex_state_struct{}
          :ets.insert(@ex_state_struct, {:state, result})
          result
        end
      end

      def put_ex_state(s) do
        init_ex_state()
        @ex_state_struct = @ex_state_struct
        :ets.insert(@ex_state_struct, {:state, s})
        s
      end
    end

    [struct, funcs]
  end

end
