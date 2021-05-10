defmodule ErotiCatWeb.Router do
  use ErotiCatWeb, :router
  use Pow.Phoenix.Router
  import Phoenix.LiveDashboard.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowEmailConfirmation]

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ErotiCatWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :logged_in do
    plug(Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
    )
  end

  pipeline :admin do
    plug(Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
    )

    plug ErotiCatWeb.EnsureRolePlug, :admin
  end

  pipeline :mods do
    plug(Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
    )

    plug ErotiCatWeb.EnsureRolePlug, [:admin, :moderator]
  end

  pipeline :creator do
    plug(Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
    )

    plug ErotiCatWeb.EnsureRolePlug, :creator
  end

  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through :browser

    get "/sign_up", RegistrationController, :new
    post "/sign_up", RegistrationController, :create

    get "/login", SessionController, :new
    post "/login", SessionController, :create
  end

  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through [:browser, :logged_in]

    get "/settings/profile", RegistrationController, :edit
    patch "/settings/profile", RegistrationController, :update
    put "/settings/profile", RegistrationController, :update

    delete "/logout", SessionController, :delete
  end

  scope "/" do
    pipe_through(:browser)

    pow_routes()
    pow_extension_routes()
  end

  scope "/", ErotiCatWeb do
    pipe_through(:browser)

    live("/", PageLive, :index)
  end

  scope "/settings", ErotiCatWeb do
    pipe_through([:browser, :logged_in])
  end

  scope "/admin" do
    # Enable admin stuff dev/test side but restrict it in prod
    pipe_through([:browser | if(Mix.env() in [:dev, :test], do: [], else: [:admin])])

    live_dashboard "/dashboard", metrics: ErotiCatWeb.Telemetry, ecto_repos: ErotiCat.Repo
  end

  # scope "/api", ErotiCatWeb do
  #   pipe_through :api
  # end
end
