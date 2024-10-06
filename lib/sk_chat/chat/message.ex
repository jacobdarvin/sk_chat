defmodule SkChat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :timestamp, :utc_datetime_usec
    field :content, :string
    field :sender_id, :id
    field :receiver_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :timestamp, :sender_id, :receiver_id])
    |> validate_required([:content, :timestamp, :sender_id, :receiver_id])
  end
end
