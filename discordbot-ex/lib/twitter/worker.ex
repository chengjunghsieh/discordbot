defmodule Twitter.Worker do
  use GenServer
  require Logger

  @interval_in_second 60 * 15
  @interval_in_millisecond @interval_in_second * 1000

  def start_link(user_info) do
    Logger.info "Twitter worker: #{inspect user_info}"
    GenServer.start_link(__MODULE__, user_info)
  end

  @impl GenServer
  def init(state) do
    send(self(), :poll)
    :timer.send_interval(@interval_in_millisecond, :poll)
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:poll, user) do
    Logger.info "Polling #{user.webhook_name}'s tweets"
    user = get_twitter_user_info(user)
    tweets = user
      |> get_tweets()
      |> Enum.reverse

    # oldest to newest
    push_to_discord(user, tweets)
    {:noreply, user}
  end


  ####################################
  # Twitter APIs
  ####################################
  """
  Get Twitter user infos (id, name, username) and update current state.

  API response:
    {:ok,
    %{
      "data" => %{
        "id" => "1554007042779594752",
        "name" => "しおんさぶ",
        "profile_image_url" => "https://pbs.twimg.com/profile_images/1554030434396188672/bUJziE0Z_normal.jpg",
        "username" => "shionchan_o"
      }
  }}

  state = user = %{
    id: "1554007042779594752",
    name: "しおんさぶ",
    profile_image_url: "https://pbs.twimg.com/profile_images/1554030434396188672/bUJziE0Z_normal.jpg",
    username: "shionchan_o"
  }
  """
  defp get_twitter_user_info(%{id: _id} = state) do
    state
  end
  defp get_twitter_user_info(state) do
    {:ok, %{"data" => data}}= Twitter.API.user_lookup(state.username)
    for {k, v} <- data, into: state do
      {String.to_atom(k), v}
    end
  end

  """
  Get user tweets with provided Twitter user id

  ## Return
    tweets
  """
  defp get_tweets(user) do
    start_time = get_last_hour_in_iso8601()
    query = %Twitter.API.UserTweetsQuery{start_time: start_time}
    tweets =
      Twitter.API.user_tweets(user.id, query)
      |> handle_tweet_response()
      |> Enum.map(&parse_tweet_response/1)
  end

  ####################################
  # Discord API's
  ####################################
  defp push_to_discord(user, []) do
    []
  end
  defp push_to_discord(user, tweets) do
    Logger.info "send #{user.webhook_name} tweets to discord"

    # [{:ok}, {:ok}, {:ok}, ...]
    result = Enum.map(tweets, fn tweet ->
      message = get_discord_payload(user, tweet)
      Discord.Webhook.send(user.webhook_id, user.webhook_token, message)
    end)
    # IO.inspect result
  end

  ####################################
  #  Utils
  ####################################
  defp get_last_hour_in_iso8601 do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.add(-@interval_in_second, :second)
    |> DateTime.to_iso8601()
  end

  defp handle_tweet_response({:ok, %{"data" => data}}), do: data
  defp handle_tweet_response({:ok, _}), do: []
  defp handle_tweet_response({:error, status, body}) do
    Logger.info "#{status}, #{inspect body}"
    []
  end

  defp parse_tweet_response(%{"referenced_tweets" => [
                                %{"id" => retweet_id, "type" => "retweeted"}
                              ]} = tweet)
  do
    %{
      id: Map.get(tweet, "id"),
      created_at: Map.get(tweet, "created_at"),
      retweet_id: retweet_id
    }
  end
  defp parse_tweet_response(tweet) do
    %{
      id: Map.get(tweet, "id"),
      created_at: Map.get(tweet, "created_at")
    }
  end

  defp get_discord_payload(user, %{retweet_id: retweet_id} = tweet) do
    content = Twitter.Config.content(user.name, tweet.created_at, tweet.id, retweet_id)
    message = %Discord.Webhook.Message{
      content: content,
      username: user.name,
      avatar_url: user.profile_image_url,
    }
  end
  defp get_discord_payload(user, tweet) do
    content = Twitter.Config.content(user.name, tweet.created_at, tweet.id)
    message = %Discord.Webhook.Message{
      content: content,
      username: user.name,
      avatar_url: user.profile_image_url,
    }
  end
end
