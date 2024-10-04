defmodule SkChat.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SkChat.Chat` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content",
        timestamp: ~U[2024-10-03 07:31:00.000000Z]
      })
      |> SkChat.Chat.create_message()

    message
  end
end
