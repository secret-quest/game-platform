defmodule SecretQuestWeb.HomeLive do
  use Phoenix.LiveView

  def mount(params, _session, socket) do
    socket = stream(socket, :presences, [])
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

  def handle_info({SecretQuestWeb.Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({SecretQuestWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end
end
