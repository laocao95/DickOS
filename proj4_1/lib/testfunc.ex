defmodule TestFunc do
    def receiveUpdateCount(count, total) do
      receive do
        {:receiveTweetUpdate, name, content} ->
          # IO.puts("count " <> Integer.to_string(count + 1))
      end
      count = count + 1
      if (count < total) do
        receiveUpdateCount(count, total)
      end
    end
  
    def receiveSearchCount(count, total) do
      receive do
        {:querySubscriberTweet_result, tweets} ->
          # IO.puts("search count" <> Integer.to_string(count))
          # IO.puts("count " <> Integer.to_string(count + 1))
        # {:queryHashTagTweet_result, tagTweets} ->
        #   # IO.puts("count " <> Integer.to_string(count + 1))
        # {:queryMentionTweet_result, mentionTweets} ->
        #   # IO.puts("count " <> Integer.to_string(count + 1))
      end
      count = count + 1
      if (count < total) do
        receiveSearchCount(count, total)
      end
    end
  
    def validateUpdateTweet(name_, content_) do
      receive do
        {:receiveTweetUpdate, name, content} ->
          if name_ == name && content_ == content do
            true
          else
            false
          end
      end
    end
  
    def validateSearchResult(tweet_) do
      receive do
        {:querySubscriberTweet_result, tweets} ->
          if tweets == tweet_ do
            true
          else
            false
          end
        {:queryHashTagTweet_result, tagTweets} ->
          if tagTweets == tweet_ do
            true
          else
            false
          end
        {:queryMentionTweet_result, mentionTweets} ->
          if mentionTweets == tweet_ do
            true
          else
            false
          end
      end
    end
  
  end