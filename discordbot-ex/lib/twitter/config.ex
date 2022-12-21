defmodule Twitter.Config do
  def users do
    [
      # %{
      #   username: "",
      #   webhook_id: "",
      #   webhook_token: "",
      #   webhook_name: ""
      # },
    ]
  end

  def tweet_url(tweet_id) do
    "https://twitter.com/i/status/" <> tweet_id
  end

  def content(_name, created_at, tweet_id) do
    "tweeted at #{created_at}:\n#{tweet_url(tweet_id)}"
  end
  def content(_name, created_at, tweet_id, retweet_id) do
    "retweeted #{tweet_url(tweet_id)} at #{created_at}:\noriginal tweet: #{tweet_url(retweet_id)}"
  end
end
