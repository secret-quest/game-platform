defmodule SecretQuestWeb.TowerChannel do
  use SecretQuestWeb, :channel

  alias SecretQuestWeb.Presence

  @impl true
  def join("tower:lobby", %{"address" => address}, socket) do
    if authorized?(address) do
      send(self(), :after_join)
      {:ok, assign(socket, :address, address)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.address, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (tower:lobby).
  @impl true
  def handle_in("message", payload, socket) do
    broadcast(socket, "message", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
