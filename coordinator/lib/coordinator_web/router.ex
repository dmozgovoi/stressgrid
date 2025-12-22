defmodule Stressgrid.CoordinatorWeb.Router do
  use Stressgrid.CoordinatorWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Stressgrid.CoordinatorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admins_only do
    plug :admin_basic_auth
  end

  scope "/", Stressgrid.CoordinatorWeb do
    pipe_through :browser

    live "/", ManagementLive, :index
    live "/management", ManagementLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Stressgrid.CoordinatorWeb do
  #   pipe_through :api
  # end

  scope "/dashboard" do
    pipe_through [:browser, :admins_only]
    live_dashboard "/", metrics: Stressgrid.CoordinatorWeb.Telemetry
  end

  defp admin_basic_auth(conn, _opts) do
    username = Application.get_env(:coordinator, :live_dashboard)[:auth_username]
    password = Application.get_env(:coordinator, :live_dashboard)[:auth_password]

    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
