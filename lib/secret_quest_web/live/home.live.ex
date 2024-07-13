defmodule SecretQuestWeb.HomeLive do
  use Phoenix.LiveView

  def mount(params, _session, socket) do
    socket =
      assign(socket, :address, params["address"])
      |> stream(:presences, [])

    socket =
      if connected?(socket) do
        SecretQuestWeb.Presence.track_user(params["address"], %{id: params["address"]})
        SecretQuestWeb.Presence.subscribe()
        stream(socket, :presences, SecretQuestWeb.Presence.list_online_users())
      else
        socket
      end

    {:ok, socket}
  end

  def handle_info({SecretQuestWeb.Presence, {:join, _presence}}, socket) do
    {:noreply, stream(socket, :presences, SecretQuestWeb.Presence.list_online_users())}
  end

  def handle_info({SecretQuestWeb.Presence, {:leave, _presence}}, socket) do
    {:noreply, stream(socket, :presences, SecretQuestWeb.Presence.list_online_users())}
  end
end
