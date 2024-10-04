# lib/sk_chat_web/channels/chat_channel.ex
defmodule SkChatWeb.ChatChannel do
  use SkChatWeb, :channel
  alias SkChat.{Chat}
  alias SkChatWeb.Presence

  # Join function for private chats
  def join("chat:" <> _chat_id, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  # Handle incoming messages
  def handle_in("message:new", %{"content" => content, "receiver_id" => receiver_id}, socket) do
    sender = socket.assigns.current_user

    # Save the message to the database
    {:ok, message} =
      Chat.create_message(%{
        content: content,
        timestamp: DateTime.utc_now(),
        sender_id: sender.id,
        receiver_id: receiver_id
      })

    # Broadcast the message to the chat channel
    broadcast!(socket, "message:new", %{
      content: content,
      sender_id: sender.id,
      receiver_id: receiver_id,
      timestamp: message.timestamp
    })

    {:noreply, socket}
  end

  # Handle presence tracking
  def handle_info(:after_join, socket) do
    user = socket.assigns.current_user

    {:ok, _} =
      Presence.track(socket, user.id, %{
        username: user.username,
        online_at: DateTime.utc_now() |> DateTime.to_unix()
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
