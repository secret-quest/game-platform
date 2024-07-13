defmodule SecretQuestWeb.HomeLive do
  use Phoenix.LiveView

  def mount(params, _session, socket) do
    socket =
      assign(socket, :address, params["address"])
      |> stream(:presences, [])
      |> stream(:messages, [])

    socket =
      if connected?(socket) do
        SecretQuestWeb.Presence.track_user(params["address"], %{id: params["address"]})
        SecretQuestWeb.Presence.subscribe()
        SecretQuestWeb.Endpoint.subscribe("tower:lobby")
        stream(socket, :presences, SecretQuestWeb.Presence.list_online_users() |> Enum.uniq())
      else
        socket
      end

    {:ok, socket}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    message_data = %{
      user: socket.assigns.address,
      body: message,
      timestamp: DateTime.utc_now(),
      id: Ecto.UUID.generate()
    }

    Phoenix.PubSub.broadcast(SecretQuest.PubSub, "tower:lobby", %{
      event: "message",
      payload: %{message: message_data}
    })

    {:noreply,
     socket
     |> stream(:presences, SecretQuestWeb.Presence.list_online_users())
     |> stream_insert(:messages, message_data)}
  end

  def handle_info(%{event: "message", payload: %{message: message = %{user: user}}}, socket) do
    if user != socket.assigns.address do
      {:noreply,
       socket
       |> stream(:presences, SecretQuestWeb.Presence.list_online_users())
       |> stream_insert(:messages, message)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({SecretQuestWeb.Presence, {:join, _presence}}, socket) do
    {:noreply, stream(socket, :presences, SecretQuestWeb.Presence.list_online_users())}
  end

  def handle_info({SecretQuestWeb.Presence, {:leave, _presence}}, socket) do
    {:noreply, stream(socket, :presences, SecretQuestWeb.Presence.list_online_users())}
  end
end
