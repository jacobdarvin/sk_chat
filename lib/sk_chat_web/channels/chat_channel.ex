# lib/sk_chat_web/channels/chat_channel.ex

defmodule SkChatWeb.ChatChannel do
  use SkChatWeb, :channel
  alias SkChat.Chat
  alias SkChatWeb.Presence

  # Handle joining the lobby channel for presence tracking
  def join("chat:lobby", _params, socket) do
    send(self(), :after_join_lobby)
    {:ok, socket}
  end

  # Handle joining user-specific channels
  def join("chat:user:" <> user_id_str, _params, socket) do
    user_id = String.to_integer(user_id_str)

    if user_id == socket.assigns.current_user.id do
      send(self(), :after_join_user)
      {:ok, assign(socket, :user_id, user_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Handle presence tracking in the lobby
  def handle_info(:after_join_lobby, socket) do
    user = socket.assigns.current_user

    {:ok, _} =
      Presence.track(socket, user.id, %{
        username: user.username,
        email: user.email,
        online_at: DateTime.utc_now() |> DateTime.to_unix()
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  # Handle any necessary actions after joining the user-specific channel
  def handle_info(:after_join_user, socket) do
    # Any additional setup after joining user-specific channel
    {:noreply, socket}
  end

  # Handle incoming messages in user-specific channels
  def handle_in("message:new", %{"content" => content, "receiver_id" => receiver_id_str}, socket) do
    sender = socket.assigns.current_user
    receiver_id = String.to_integer(receiver_id_str)

    message_attrs = %{
      content: content,
      sender_id: sender.id,
      receiver_id: receiver_id,
      timestamp: DateTime.utc_now()
    }

    # Log the message attributes
    IO.puts("Attempting to create message with attrs: #{inspect(message_attrs)}")

    case Chat.create_message(message_attrs) do
      {:ok, message} ->
        IO.puts("Message created successfully: #{inspect(message)}")
        broadcast_to_users(message)
        {:noreply, socket}

      {:error, changeset} ->
        errors = format_changeset_errors(changeset)
        IO.puts("Failed to create message: #{inspect(errors)}")
        {:reply, {:error, %{errors: errors}}, socket}
    end
  end

  defp broadcast_to_users(message) do
    SkChatWeb.Endpoint.broadcast!(
      "chat:user:#{message.sender_id}",
      "message:new",
      message_payload(message)
    )

    SkChatWeb.Endpoint.broadcast!(
      "chat:user:#{message.receiver_id}",
      "message:new",
      message_payload(message)
    )
  end

  defp message_payload(message) do
    %{
      id: message.id,
      content: message.content,
      timestamp: message.inserted_at,
      sender_id: message.sender_id,
      receiver_id: message.receiver_id
    }
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
