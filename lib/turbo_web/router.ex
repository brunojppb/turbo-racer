defmodule TurboWeb.Router do
  use TurboWeb, :router

  import TurboWeb.UserAuth
  import TurboWeb.ArtifactAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TurboWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_app_access
    plug :fetch_has_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TurboWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Turborepo API endpoints. Reverse-engineered from the Turborepo source
  # See: https://github.com/vercel/turborepo/blob/main/cli/internal/client/client.go
  scope "/v8", TurboWeb do
    pipe_through [:require_bearer_token]
    get "/artifacts/:hash", ArtifactController, :show
    put "/artifacts/:hash", ArtifactController, :create
    post "/artifacts/events", ArtifactController, :events
  end

  # Turborepo analytics endpoints.
  # Adding dummy responses for now. We can explore some dashboards later around these.
  scope "/v2", TurboWeb do
    get "/teams", TeamController, :teams
    get "/user", TeamController, :user
  end

  # To allow user signups, first make sure that signup is enabled in the admin settings
  scope "/", TurboWeb do
    pipe_through [
      :browser,
      :redirect_if_user_is_authenticated,
      :ensure_signup_access
    ]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
  end

  ## Authentication routes
  scope "/", TurboWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", TurboWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    get "/teams", TeamController, :index
    get "/teams/new", TeamController, :new
    post "/teams", TeamController, :create
    delete "/teams/:id", TeamController, :delete

    get "/teams/:team_id/tokens", TeamTokenController, :index
    post "/teams/:team_id/tokens", TeamTokenController, :create
    delete "/teams/:team_id/tokens/:id", TeamTokenController, :delete
  end

  scope "/", TurboWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  # Admin routes
  scope "/admin", TurboWeb.Admin do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    get "/settings/access", AppAccessController, :index
    put "/settings/access", AppAccessController, :update
  end

  # Telemetry/Operations endpoints (Behind Admin auth)
  scope "/ops", TurboWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]
    live_dashboard "/dashboard", metrics: TurboWeb.Telemetry
  end

  # Health check endpoints
  scope "/management", TurboWeb do
    get "/health", HealthCheckController, :index
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
