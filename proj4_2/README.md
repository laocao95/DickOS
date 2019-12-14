# Proj4_2

## Group

  * Zhiwei Cao 5094-5378
  * Xiyuan Zheng 6191-9957

## Functionality implemented

  * subscribe
  * post tweet(including hashtag#, mention@)
  * retweet
  * search hashtag
  * search tweets mentioning me
  * search tweets of my subscribers

## How to run:

  ### For browser

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`
  * Now you can visit [`localhost:4000`](http://127.0.0.1:4000/) from your browser.

  ### For test

  * `mix test`

## Scenarios

  * First of all, the user can register an account. If the account already exists, the user will login to the twitter system.
  * Users can send a tweet. Tweets can have hashtags (e.g. #COP5615) and mentions(e.g. @John). Users can search all tweets mentioned the user, and can also search all tweets with specific hashtag.
  * If the user is connected, deliver the above types of tweets live.(without querying) When a tweet is sent to the server, the server will send the notification of the tweet to related clients.
  * And users can subscribe other users. After the user subscribe others, the user will get notification once the subscriber post a tweet.
  * Also, users can retweet other users tweets, and the content of the retweet is still the same.
  * Finally, users can search all tweets of the user's subscribers. And the system will show all tweets send by the user's subscribers in history.


