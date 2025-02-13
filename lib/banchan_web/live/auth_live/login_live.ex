defmodule BanchanWeb.LoginLive do
  @moduledoc """
  Account Login
  """
  use BanchanWeb, :surface_view

  alias Surface.Components.Form

  alias BanchanWeb.Components.Form.{Checkbox, EmailInput, Submit, TextInput}
  alias BanchanWeb.Components.Layout
  alias BanchanWeb.Endpoint

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket, false)

    {:ok,
     assign(socket,
       changeset: User.login_changeset(%User{}, %{}),
       trigger_submit: false
     )}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <Layout current_user={@current_user} flashes={@flash}>
      <div class="shadow bg-base-200 text-base-content">
        <div class="p-6">
          <h1 class="text-2xl">Log in</h1>
          <Form
            class="col-span-1"
            for={@changeset}
            action={Routes.user_session_path(Endpoint, :create)}
            change="change"
            submit="submit"
            trigger_action={@trigger_submit}
          >
            <EmailInput name={:email} icon="envelope" opts={required: true} />
            <TextInput name={:password} icon="lock" opts={required: true, type: :password} />
            <TextInput name={:mfa_token} icon="mobile-alt" opts={maxlength: 6, placeholder: "optional"} />
            <Checkbox name={:remember_me}>Keep me logged in for 60 days.</Checkbox>
            <Submit changeset={@changeset} label="Log in" />
          </Form>
        </div>
      </div>
    </Layout>
    """
  end

  @impl true
  def handle_event("change", val, socket) do
    changeset =
      %User{}
      |> User.login_changeset(val["user"])
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", val, socket) do
    changeset =
      %User{}
      |> User.login_changeset(val["user"])

    {:noreply, assign(socket, changeset: changeset, trigger_submit: true)}
  end
end
