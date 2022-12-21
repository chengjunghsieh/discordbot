import Config

config :nostrum,
  token: "",  # add discord token
  dev: false

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env}.exs"
import_config "#{Mix.env}.secrets.exs"
