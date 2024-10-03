defmodule SkChatWeb.FallbackController do
  use SkChatWeb, :controller

  # Handles errors returned from Ecto's insert/update/delete
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: translate_errors(changeset)})
  end

  # Handles not found
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Not found"})
  end

  # Handles all other errors
  def call(conn, {:error, reason}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: to_string(reason)})
  end

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
