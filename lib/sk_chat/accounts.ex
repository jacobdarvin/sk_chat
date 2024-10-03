defmodule SkChat.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias SkChat.Repo

  alias SkChat.Accounts.User

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  def authenticate_user(username, password) do
    user = get_user_by_username(username)

    cond do
      user && Bcrypt.verify_pass(password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :invalid_password}

      true ->
        {:error, :user_not_found}
    end
  end
end
