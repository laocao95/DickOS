defmodule SearchActor do
    use GenServer

    def init(state) do
        {:ok, state}
    end

    #querySubscriberTweet handler
    def handle_cast({:querySubscriberTweet, name, clientPID}, state) do
        [{_, subscribers}] = :ets.lookup(:nameSubscribers, name)
        # IO.inspect(subscribers)
        tweets = Enum.map(subscribers, fn {subscriberName, subscriberPID} -> 
            [{_, nameTweets}] = :ets.lookup(:nameTweets, subscriberName)
            # IO.inspect(nameTweets)
            nameTweets
        end) 
        |> List.flatten()

        GenServer.cast(clientPID, {:querySubscriberTweet_result, tweets})
        {:noreply, state}
    end
    
    #queryHashTagTweet handler
    def handle_cast({:queryHashTagTweet, name, clientPID, hashTag}, state) do        
        tagTweets = case :ets.lookup(:tagTweets, hashTag) do
            [{_, tagTweets}] ->
                tagTweets
            [] ->
                []
        end
        GenServer.cast(clientPID, {:queryHashTagTweet_result, tagTweets})
        {:noreply, state}
    end

    #queryMentionTweet handler
    def handle_cast({:queryMentionTweet, name, clientPID}, state) do
        mentionTweets = case :ets.lookup(:mentionTweets, name) do
            [{_, mentionTweets}] ->
                mentionTweets
            [] ->
                []
        end
        GenServer.cast(clientPID, {:queryMentionTweet_result, mentionTweets})
        {:noreply, state}
    end
end