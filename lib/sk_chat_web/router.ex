defmodule SkChatWeb.Router do
  use SkChatWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug SkChatWeb.AuthPipeline
  end

  scope "/api", SkChatWeb do
    pipe_through :api

    post "/login", SessionController, :create
    post "/register", RegistrationController, :create
  end

  scope "/api", SkChatWeb do
    pipe_through [:api, :api_auth]

    get "/messages", MessageController, :index
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sk_chat, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: SkChatWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
