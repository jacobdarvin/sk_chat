# lib/sk_chat_web/channels/chat_channel.ex

defmodule SkChatWeb.ChatChannel do
  use SkChatWeb, :channel
  alias SkChat.Chat
  alias SkChatWeb.Presence

  def join("chat:" <> chat_id, _params, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :chat_id, chat_id)}
  end

  def handle_info(:after_join, socket) do
    user = socket.assigns.current_user

    Presence.track(socket, user.id, %{
      username: user.username,
      online_at: DateTime.utc_now() |> DateTime.to_unix()
    })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("message:new", %{"content" => content}, socket) do
    sender = socket.assigns.current_user
    chat_id = socket.assigns.chat_id

    # Determine if it's a global chat
    {_receiver_id, message_attrs} =
      if chat_id == "0" do
        {nil, %{content: content, sender_id: sender.id}}
      else
        receiver_id = String.to_integer(chat_id)

        {
          receiver_id,
          %{
            content: content,
            sender_id: sender.id,
            receiver_id: receiver_id
          }
        }
      end

    case Chat.create_message(message_attrs) do
      {:ok, message} ->
        broadcast!(socket, "message:new", %{
          id: message.id,
          content: message.content,
          timestamp: message.inserted_at,
          sender_id: message.sender_id,
          receiver_id: message.receiver_id
        })

        {:noreply, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
