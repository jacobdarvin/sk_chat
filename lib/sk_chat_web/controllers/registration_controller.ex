defmodule SkChatWeb.RegistrationController do
  use SkChatWeb, :controller

  alias SkChat.{Accounts, Guardian}

  action_fallback SkChatWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        # Generate JWT token
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        # Return user data and token
        conn
        |> put_status(:created)
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

      {:error, changeset} ->
        # Handle errors
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: translate_errors(changeset)})
    end
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
