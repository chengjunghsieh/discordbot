defmodule Twitter.API.UserTweetsQuery do
  defstruct [
    :since_id,
    :start_time,  # YYYY-MM-DDTHH:mm:ssZ (ISO 8601/RFC 3339), UTC timestamp
    :pagination_token,
    max_results: 100,
    "tweet.fields": "created_at,id",
    expansions: "referenced_tweets.id", # author_id
    # "user.fields": "name,username,id",
  ]
end

defmodule Twitter.API do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.twitter.com/2"
  plug Tesla.Middleware.Headers, [{"authorization", "Bearer #{Application.get_env(:exbot, :twitter_api_token, :none)}"}]
  plug Tesla.Middleware.JSON

  @doc"""
  Call Twitter User Lookup API.

  ## Parameters

    - username: Twitter username (handle)

  ## Examples

      iex(1)> Twitter.API.user_lookup("95rn16")
      {:ok,
      %{
        "data" => %{
          "id" => "1554007042779594752",
          "name" => "しおんさぶ",
          "profile_image_url" => "https://pbs.twimg.com/profile_images/1554030434396188672/bUJziE0Z_normal.jpg",
          "username" => "shionchan_o"
        }
      }}
  """
  def user_lookup(username) do
    query = %{
      "user.fields": "profile_image_url"
    }
    {:ok, response} = get("/users/by/username/" <> username, query: query)
    case response.status do
      200 -> {:ok, response.body}
      _ -> {:error, response.status, response.body}
    end
  end

  @doc"""

  ## Parameters
  - opts
    - last_tweet_id
    - next_page_token

  ## Example
      iex> Twitter.API.user_tweets("232255031")
      {:ok,
        %{
          "data" => [
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-12T05:01:08.000Z",
              "id" => "1524615638035345408",
              "text" => "GW含めて5月、一度も配信できてなくてすみません(´•ω•̥`)実は心と体を休めてます。もうずっと気持ちが塞いでしまっていて、PCを付けたりゲームをする気持ちが全く起きなくて…主治医の指示通り、生活の基礎をまず正してます！待ってて欲しいです🙇‍♂️報告ツイットでした💡𓈒𓂂𓏸"
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-10T08:51:07.000Z",
              "id" => "1523948739538595840",
              "text" => "@muzologhacholo4 計らないで目分量で作ったからとてもうれしい！"
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-10T07:58:13.000Z",
              "id" => "1523935425307766785",
              "text" => "苺がいっぱいあったからカップケーキたくさん作った🧁💕 https://t.co/pOkjpb3s3F"
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-09T01:28:11.000Z",
              "id" => "1523474882897784832",
              "text" => "寝坊しちゃいまちた((ﾉ)`ω･(ヾ))おはよぅぅ～"
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-08T07:56:48.000Z",
              "id" => "1523210294344163328",
              "text" => "！ https://t.co/fRHgATvWem"
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-07T07:19:29.000Z",
              "id" => "1522838512537866240",
              "text" => "💜 https://t.co/OBCol5r8GZ"
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-06T02:57:40.000Z",
              "id" => "1522410237319589889",
              "text" => "@RancorSNP hello!!!!Hope you have a wonderful day."
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-06T02:55:43.000Z",
              "id" => "1522409748267941888",
              "text" => "@koa_10rum それくらいの煮込みが美味しいの～🤝(伝われ)"
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-06T02:43:45.000Z",
              "id" => "1522406734266249216",
              "text" => "残りの野菜で作ったのだけど、キャベツがなかったので冷蔵庫にあったレタス入れてます🐱🥬残りの3分前くらいにレタス入れるととても美味しいのでおすすめれすれたす\\╮╯╭/栄養いっぱいみんなにも作ってあげたいでふ🍽"
            },
            %{
              "author_id" => "232255031",
              "created_at" => "2022-05-06T01:56:20.000Z",
              "id" => "1522394803606286336",
              "text" => "手作りスープ( ˆ ˆ )/♡んま https://t.co/CoR8m64Lfy"
            }
          ],
          "includes" => %{
            "users" => [
              %{
                "id" => "232255031",
                "name" => "みけねこ！",
                "username" => "95rn16"
              }
            ]
          },
          "meta" => %{
            "newest_id" => "1524615638035345408",
            "next_token" => "7140dibdnow9c7btw421dyyadu7pewm7gntfnr9cws75i",
            "oldest_id" => "1522394803606286336",
            "result_count" => 10
          }
        }}

        iex> q = %Twitter.API.UserTweetsQuery{pagination_token: "7140dibdnow9c7btw421dyyadu7pewm7gntfnr9cws75i"}
        %Twitter.API.UserTweetsQuery{
          expansions: "author_id",
          max_results: 10,
          pagination_token: "7140dibdnow9c7btw421dyyadu7pewm7gntfnr9cws75i",
          since_id: nil,
          "tweet.fields": "created_at,id",
          "user.fields": "name,username,id"
        }
        iex> Twitter.API.user_tweets("232255031", q)
        {:ok,
         %{
           "data" => [
             %{
               "author_id" => "232255031",
               "created_at" => "2022-05-03T10:52:25.000Z",
               "id" => "1521442550758150145",
               "text" => "右目が…疼くっ…！！！！！！！！"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-05-02T02:43:19.000Z",
               "id" => "1520957075668738048",
               "text" => "朝ごはん遅くなったけど美味しくでけた~~~ https://t.co/UgSHr7p5kw"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-05-01T06:28:09.000Z",
               "id" => "1520651268691496960",
               "text" => "@Kurotubaki09 優しーありがとー💓"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-05-01T06:27:01.000Z",
               "id" => "1520650984090968064",
               "text" => "@kuon_cue ダンボールひとつも開けてないww"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-05-01T06:20:57.000Z",
               "id" => "1520649456697626629",
               "text" => "@yanyantsukebo_4 ここだと誰にも会えなくて意味もないし病むから早くひっこしたいんだ。。"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-05-01T06:19:08.000Z",
               "id" => "1520649000890019841",
               "text" => "この間引っ越したけど早く引っ越した~~~い！！！(  ߹꒳​߹ )あの場所に帰りたい~~~！！！GW中に決めちゃうぞっ！！"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-05-01T01:35:30.000Z",
               "id" => "1520577622950182913",
               "text" => "寝おきからひどい目眩が…こんな日に…体調良くなったらまたスケジュール立てて配信する(´；ω；`)具合悪すぎる、ごめんなさい…"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-04-30T11:39:12.000Z",
               "id" => "1520367157858926592",
               "text" => "@Jsolorzanoale okです！事前にoffにしてあります(´˘`＊)Thanks♡"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-04-30T11:37:05.000Z",
               "id" => "1520366626147016704",
               "text" => "@Rirulight チャンネル一覧に出ないのですよんよん(  ߹꒳​߹ )ううう～"
             },
             %{
               "author_id" => "232255031",
               "created_at" => "2022-04-30T07:04:36.000Z",
               "id" => "1520298054427246593",
               "text" => "🖕( ˙꒳​˙  )🖕 https://t.co/eHEyuNEO7t"
             }
           ],
           "includes" => %{
             "users" => [
               %{
                 "id" => "232255031",
                 "name" => "みけねこ！",
                 "username" => "95rn16"
               }
             ]
           },
           "meta" => %{
             "newest_id" => "1521442550758150145",
             "next_token" => "7140dibdnow9c7btw421duojarricrvuv1nft6ctnmdkj",
             "oldest_id" => "1520298054427246593",
             "previous_token" => "77qpymm88g5h9vqklurcucc7kc838sps95wer1z3x4cad",
             "result_count" => 10
           }
         }}


      iex> q = %Twitter.API.UserTweetsQuery{since_id: "1523948739538595840"}
      %Twitter.API.UserTweetsQuery{
        expansions: "author_id",
        max_results: 10,
        pagination_token: nil,
        since_id: "1523948739538595840",
        "tweet.fields": "created_at,id",
        "user.fields": "name,username,id"
      }
      iex>  Twitter.API.user_tweets("232255031", q)
      {:ok,
       %{
         "data" => [
           %{
             "author_id" => "232255031",
             "created_at" => "2022-05-12T05:01:08.000Z",
             "id" => "1524615638035345408",
             "text" => "GW含めて5月、一度も配信できてなくてすみません(´•ω•̥`)実は心と体を休めてます。もうずっと気持ちが塞いでしまっていて、PCを付けたりゲームをする気持ちが全く起きなくて…主治医の指示通り、生活の基礎をまず正してます！待ってて欲しいです🙇‍♂️報告ツイットでした💡𓈒𓂂𓏸"
           }
         ],
         "includes" => %{
           "users" => [
             %{
               "id" => "232255031",
               "name" => "みけねこ！",
               "username" => "95rn16"
             }
           ]
         },
         "meta" => %{
           "newest_id" => "1524615638035345408",
           "oldest_id" => "1524615638035345408",
           "result_count" => 1
         }
       }}


  """
  def user_tweets(user_id, opts \\ %Twitter.API.UserTweetsQuery{}) do
    opts = Map.from_struct(opts)
    query = Enum.reduce(opts, %{}, fn {k, v}, acc ->
      if v do
        Map.put(acc, k, v)
      else
        acc
      end
    end)

    {:ok, response} = get("/users/" <> user_id <> "/tweets",
                          query: query)
    case response.status do
      200 -> {:ok, response.body}
      _ -> {:error, response.status, response.body}
    end
  end
end
