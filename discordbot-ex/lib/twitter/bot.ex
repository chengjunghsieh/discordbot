defmodule Twitter.Bot do
  use Supervisor
  require Logger

  def start_link(_) do
    Logger.info "Starting Twitter Bot."
    Supervisor.start_link(__MODULE__, Twitter.Config.users, name: __MODULE__)
  end

  @impl Supervisor
  def init(users) do
    children =
      for user <- users do
        Supervisor.child_spec({Twitter.Worker, user}, id: user)
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
