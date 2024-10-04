defmodule SkChatWeb.Presence do
  use Phoenix.Presence,
    otp_app: :sk_chat,
    pubsub_server: SkChat.PubSub
end
