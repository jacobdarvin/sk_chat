# lib/sk_chat_web/channels/user_socket.ex
defmodule SkChatWeb.UserSocket do
  use Phoenix.Socket
  alias SkChat.Guardian

  ## Channels
  channel "chat:*", SkChatWeb.ChatChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    case Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        {:ok, assign(socket, :current_user, user)}

      {:error, _reason} ->
        :error
    end
  end

  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
