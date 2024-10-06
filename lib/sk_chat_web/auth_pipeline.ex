# lib/sk_chat_web/auth_pipeline.ex

defmodule SkChatWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :sk_chat,
    module: SkChat.Guardian,
    error_handler: SkChatWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
