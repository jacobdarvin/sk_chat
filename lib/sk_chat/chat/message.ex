defmodule SkChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :sender_id, :integer
    field :receiver_id, :integer
    field :timestamp, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :timestamp])
    |> validate_required([:content, :timestamp])
  end
end
