defmodule ExternalState do
  @moduledoc """
  Support storing all or part of some state externally to the owning pid(s).
  Builds on ETS existing functionality.
  """

  @doc """
  The __using__/1 macro introduces the external state data structure and
  the module functions used to interact with the external state.

  ## Parameters
  - kwl The keyword list describing the using module's external state. The
    following are supported:

    - {:persist, boolean} Set persist to true for the external state to
      be persisted after the pid that calls init_ex_state/1 exits. This is
      the default.
    - {:props, struct_def} Set the properties of the external state
      structure. The struct_def is a keyword list identical to what you would
      use to define any structure.
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

      @doc """
      Get the default / initial external state.
      ## Returns
      - %@ex_state_struct{}
      """
      def default_ex_state, do: %@ex_state_struct{}

      @doc """
      Initialize the external state. This must be called once, usually in a
      GenServer.init function. This will also set the owner pid of non-persisted
      state.

      ## Returns
      - default_ex_state() if the external state was newly created
      - :ok if the external state was already created
      """
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

      @doc """
      Get the external state

      ## Returns
      - %@ex_state_struct{} The current external state
      - nil The external state has not been initialized yet
      """
      def get_ex_state do
        try do
          case :ets.lookup(@ex_state_struct, :state) do
            [{:state, result}] ->
              result

            _ ->
              put_ex_state(default_ex_state())
          end
        rescue _ -> nil
        end
      end

      @doc """
      Set the external state

      ## Parameters
      - s The new external state; must be shaped as a  %@ex_state_struct{}

      ## Returns
      - s When the external state was set
      - nil The external state has not been initialized yet
      """
      def put_ex_state(s) do
        try do
          :ets.insert(@ex_state_struct, {:state, s})
          s
        rescue _ ->
          nil
        end
      end

      @doc """
      Merge the external state with a keyword list or map

      ## Parameters
      - kwl_or_map A keyword list or a map
        - If keyword list, this turned into a map with Map.new/1 then processed
          as a map merge.
        - If map, this is merged with the current state and then put_ex_state/1

      ## Returns
      - The result of put_ex_state/1
      """
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
