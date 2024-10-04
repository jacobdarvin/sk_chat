defmodule SkChatWeb.SessionController do
  use SkChatWeb, :controller

  alias SkChat.{Accounts, Guardian}

  action_fallback SkChatWeb.FallbackController

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Accounts.authenticate_user(username, password) do
      {:ok, user} ->
        # Generate JWT token
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        # Return user data and token
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
