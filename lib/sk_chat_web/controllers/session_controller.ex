defmodule SkChatWeb.SessionController do
  use SkChatWeb, :controller

  alias SkChat.{Accounts, Guardian}

  action_fallback SkChatWeb.FallbackController

  def create(conn, %{"username" => username, "password" => password}) do
    case Accounts.authenticate_user(username, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            user: %{
              id: user.id,
              username: user.username,
              email: user.email
            },
            token: token
          }
        })

      {:error, :invalid_password} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid password"})

      {:error, :user_not_found} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "User not found"})
    end
  end
end
