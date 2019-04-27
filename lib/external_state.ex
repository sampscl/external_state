defmodule ExternalState do
  @moduledoc """
  Support storing all or part of some state externally to the owning pid(s).
  Builds on ETS existing functionality.
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

      def default_ex_state, do: %@ex_state_struct{}

      def init_ex_state do
        case @external_state_persist do
          true ->
            if :ets.info(@ex_state_struct) == :undefined do
              EtsOwner.create_table(@ex_state_struct, :set)
              put_ex_state(default_ex_state())
            end

          false ->
            try do
              if :ets.info(@ex_state_struct) == :undefined do
                :ets.new(@ex_state_struct, [:public, :named_table, :set])
                put_ex_state(default_ex_state())
              end
            rescue _ -> :ok
            end
        end
      end

      def get_ex_state do
        case :ets.lookup(@ex_state_struct, :state) do
          [{:state, result}] ->
            result

          _ ->
            put_ex_state(default_ex_state())
        end
      end

      def put_ex_state(s) do
        @ex_state_struct = @ex_state_struct
        :ets.insert(@ex_state_struct, {:state, s})
        s
      end

      def merge_ex_state(kwl_or_map)
      def merge_ex_state(kwl) when is_list(kwl) do
        kwl
        |> Map.new(kwl)
        |> merge_ex_state()
      end
      def merge_ex_state(m) when is_map(m) do
        m
        |> Map.merge(get_ex_state())
        |> put_ex_state()
      end
    end

    [struct, funcs]
  end

end
