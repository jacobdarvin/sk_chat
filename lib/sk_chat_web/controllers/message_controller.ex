defmodule SkChatWeb.MessageController do
  use SkChatWeb, :controller

  alias SkChat.Accounts
  alias SkChat.Chat
  alias SkChat.Guardian

  action_fallback SkChatWeb.FallbackController

  def index(conn, %{"receiver_id" => receiver_id}) do
    user = Guardian.Plug.current_resource(conn)
    receiver_id = String.to_integer(receiver_id)

    case Accounts.get_user!(receiver_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Receiver not found"})

      _receiver ->
        messages = Chat.get_messages_between_users(user.id, receiver_id)

        messages_data =
          Enum.map(messages, fn message ->
            %{
              id: message.id,
              content: message.content,
              timestamp: message.inserted_at,
              sender_id: message.sender_id,
              receiver_id: message.receiver_id
            }
          end)

        conn
        |> put_status(:ok)
        |> json(%{data: %{messages: messages_data}})
    end
  end
end
