# lib/sk_chat/guardian.ex

defmodule SkChat.Guardian do
  use Guardian, otp_app: :sk_chat

  alias SkChat.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user!(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
