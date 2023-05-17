defmodule StanleyStella.Application do
  use Application

  def start(_, _) do
    Supervisor.start_link(
      [
        Plug.Cowboy.child_spec(
          scheme: :http,
          plug: StanleyStella.Endpoint,
          options: [port: 4000]
        )
      ],
      strategy: :one_for_one,
      name: StanleyStella.Supervisor
    )
  end
end
