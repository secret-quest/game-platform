defmodule SecretQuestWeb.HomeLive do
  use Phoenix.LiveView

  alias SecretQuest.RiddleDivider

  def mount(params, _session, socket) do
    riddle_parts = RiddleDivider.divide_riddle_for_level(1)

    socket =
      assign(socket, :address, params["address"])
      |> assign(:riddle_parts, riddle_parts)
      |> assign(:timer, 300)
      |> assign(:running, true)
      |> stream(:presences, [])
      |> stream(:messages, [
        %{
          user: "floor-admin",
          body: "Welcome to the first floor game! Please wait for other players to join.",
          timestamp: DateTime.utc_now(),
          id: Ecto.UUID.generate()
        }
      ])

    Process.send_after(self(), :tick, 1000)

    socket =
      if connected?(socket) do
        SecretQuestWeb.Presence.track_user(params["address"], %{id: params["address"]})
        SecretQuestWeb.Presence.subscribe()
        SecretQuestWeb.Endpoint.subscribe("tower:lobby")

        socket
        |> stream(:presences, SecretQuestWeb.Presence.list_online_users())
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

  def handle_info(:tick, socket) do
    if socket.assigns.running do
      new_timer_time = socket.assigns.timer - 1

      if new_timer_time > 0 do
        Process.send_after(self(), :tick, 1000)

        {:noreply,
         assign(socket, :timer, new_timer_time)
         |> stream(:presences, SecretQuestWeb.Presence.list_online_users())}
      else
        {:noreply,
         socket
         |> assign(:running, false)
         |> assign(:timer, 0)
         |> stream(:presences, SecretQuestWeb.Presence.list_online_users())}
      end
    else
      {:noreply, stream(socket, :presences, SecretQuestWeb.Presence.list_online_users())}
    end
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

  def handle_info({SecretQuestWeb.Presence, {action, _presence}}, socket) when action in [:leave, :join] do
    {:noreply,
    socket
    |> stream(:presences, SecretQuestWeb.Presence.list_online_users())
  }
  end
end
