defmodule Ryujin.VoiceSupervisor do
  @moduledoc """
  Dynamic supervisor responsible for spawning one process per active voice session.
  """

  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, :ok, Keyword.put_new(opts, :name, __MODULE__))
  end

  @impl true
  @spec init(:ok) ::
          {:ok,
           %{
             extra_arguments: list(),
             intensity: non_neg_integer(),
             max_children: :infinity | non_neg_integer(),
             period: pos_integer(),
             strategy: :one_for_one
           }}
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
