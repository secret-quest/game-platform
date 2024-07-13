defmodule SecretQuestWeb.HomeLive do
  use Phoenix.LiveView

  alias SecretQuest.RiddleDivider
  alias SecretQuest.EmojiConverter
  alias SecretQuest.RiddleEvaluator

  def mount(params, _session, socket) do
    {riddle_parts, hash} = RiddleDivider.divide_riddle_for_level(1)

    socket =
      assign(socket, :address, params["address"])
      |> assign(:riddle_parts, riddle_parts)
      |> assign(:timer, 10)
      |> assign(:solved, false)
      |> assign(:hash, hash)
      |> assign(:running, true)
      |> stream(:presences, [])
      |> stream(:messages, [])

    Process.send_after(self(), :tick, 1000)

    socket =
      if connected?(socket) do
        SecretQuestWeb.Presence.track_user(params["address"], %{id: params["address"]})
        SecretQuestWeb.Presence.subscribe()
        SecretQuestWeb.Endpoint.subscribe("tower:lobby")

        socket
        |> stream(:presences, SecretQuestWeb.Presence.list_online_users())
        |> stream(:messages, [
          %{
            user: "floor-admin",
            body:
              "Welcome to the first floor 🗺️ You have limited time to solve this riddle ⏲️ If you miss riddle pieces, get them from others 🧩 However you don't know if they lie or not 😈 If they lie, you can try to vote them out 🗳️ Eliminate all bad agents before you get eliminated 💪 Good luck!",
            timestamp: DateTime.utc_now(),
            id: Ecto.UUID.generate()
          }
        ])
      else
        socket
      end

    {:ok, socket}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    if socket.assigns.running do
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

      else
        solved? = RiddleEvaluator.correct_riddle_answer?(socket.assigns.hash, message)

        {:noreply,
         socket
         |> assign(:solved, solved?)
         |> stream(:presences, SecretQuestWeb.Presence.list_online_users())
         |> stream(:messages, [
          %{
            user: "floor-admin",
            body:
              "Your answer is #{if solved?, do: "correct. Time for the next level!", else: "incorrect. You have been eliminated!"}",
            timestamp: DateTime.utc_now(),
            id: Ecto.UUID.generate()
          }
        ], reset: true)}
    end
  end

  def handle_info(:tick, socket) do
    if socket.assigns.running do
      Process.send_after(self(), :tick, 1000)
      if socket.assigns.timer > 0 do
        {:noreply,
        socket |> assign(:timer, socket.assigns.timer - 1) |> stream(:presences, SecretQuestWeb.Presence.list_online_users())}
      else
        {:noreply, assign(socket, :running, false)}
      end
    else
      {:noreply,
       socket
       |> stream(:presences, SecretQuestWeb.Presence.list_online_users())}
    end
  end

  def handle_info(%{event: "message", payload: %{message: message = %{user: user}}}, socket) do
    if user != socket.assigns.address and socket.assigns.running do
      {:noreply,
       socket
       |> stream(:presences, SecretQuestWeb.Presence.list_online_users())
       |> stream_insert(:messages, message)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({SecretQuestWeb.Presence, {action, _presence}}, socket)
      when action in [:leave, :join] do
    {:noreply,
     socket
     |> stream(:presences, SecretQuestWeb.Presence.list_online_users())}
  end

  def last_four_characters(binary) when is_binary(binary) do
    binary
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.take(4)
    |> Enum.reverse()
    |> Enum.join()
  end
end
