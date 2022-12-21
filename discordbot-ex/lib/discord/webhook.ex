defmodule Discord.Webhook.Message do
  defstruct [:content, :files, :embeds,
             :username, :avatar_url,
             :tts, :flags, :thread_id]
end

defmodule Discord.Webhook do
  alias Webhook.Message
  alias Nostrum.Api

  @doc"""
  API doc:
    https://hexdocs.pm/nostrum/Nostrum.Api.html#execute_webhook/4
  """
  # https://discord.com/api/webhooks/895690504447090698/sAqQTL7_aRMRPhvMsM-faKCVz-Yvw_nDy1rS5rVMBrRoawRQksLwsPRiR2g4vdbpngND
  def send(webhook_id, webhook_token, message, wait \\ false) do
    m = for {k, v} <- Map.from_struct(message), v != nil, into: %{}, do: {k, v}
    Api.execute_webhook(webhook_id, webhook_token, m, wait)
  end
end
