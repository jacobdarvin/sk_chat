defmodule SkChatWeb.MessageController do
  use SkChatWeb, :controller

  alias SkChat.Chat
  alias SkChat.Guardian

  action_fallback SkChatWeb.FallbackController

  def index(conn, %{"receiver_id" => receiver_id}) do
    user = Guardian.Plug.current_resource(conn)
    messages = Chat.get_messages_between_users(user.id, String.to_integer(receiver_id))

    conn
    |> put_status(:ok)
    |> json(%{data: %{messages: messages}})
  end
end
