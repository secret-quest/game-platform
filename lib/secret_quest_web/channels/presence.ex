defmodule SecretQuestWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :secret_quest,
    pubsub_server: SecretQuest.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    for {address, %{metas: [meta | metas]}} <- presences, into: %{} do
      # TODO: generate random character for user
      {address, %{metas: [meta | metas], id: address, user: %{}}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(SecretQuest.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(SecretQuest.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end

  # Also add agents
  def list_online_users() do
    list("online_users")
    |> Map.values()
  end

  def track_user(address, params), do: track(self(), "online_users", address, params)

  def subscribe(), do: Phoenix.PubSub.subscribe(SecretQuest.PubSub, "proxy:online_users")
end
