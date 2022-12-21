defmodule Exbot do
  use Application
  use Supervisor

  def start(_type, _args) do
    children = [
      {Twitter.Bot, :start_link}
    ]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
