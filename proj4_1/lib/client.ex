defmodule Client do
    use GenServer

    def init(state) do
        #state = {myName, serverPID, testServerPID}
        {:ok, state}
    end

    def handle_call({:subscribe, subscribeToName}, _from, state) do
        {myName, serverPID, testServerPID} = state
        GenServer.call(serverPID, {:subscribe, myName, subscribeToName})
        {:reply, state, state}        
    end

    def handle_cast({:tweet, content}, state) do
        {myName, serverPID, testServerPID} = state
        GenServer.cast(serverPID, {:tweet, myName, content})
        {:noreply, state}
    end

    def handle_cast({:retweet, tweet}, state) do
        {myName, serverPID, testServerPID} = state
        GenServer.cast(serverPID, {:retweet, myName, tweet})
        {:noreply, state}
    end

    #from frontEnd
    def handle_cast({:querySubscriberTweet}, state) do
        {myName, serverPID, testServerPID} = state
        GenServer.cast(serverPID, {:querySubscriberTweet, myName, self()})
        {:noreply, state}
    end

    def handle_cast({:queryHashTagTweet, hashTag}, state) do
        {myName, serverPID, testServerPID} = state
        GenServer.cast(serverPID, {:queryHashTagTweet, myName, self(), hashTag})
        {:noreply, state}
    end

    def handle_cast({:queryMentionTweet}, state) do
        {myName, serverPID, testServerPID} = state
        GenServer.cast(serverPID, {:queryMentionTweet, myName, self()})
        {:noreply, state}
    end
    
    #server callback
    def handle_cast({:querySubscriberTweet_result, tweets}, state) do
        {myName, serverPID, testServerPID} = state
        # tweets = GenServer.call(serverPID, {:querySubscriberTweet, myName})
        if testServerPID == false do
            IO.puts("receive search result")
            #TODO: notify frontEnd
        else
            send testServerPID, {:querySubscriberTweet_result, tweets}
        end

        {:noreply, state}
    end

    def handle_cast({:queryHashTagTweet_result, tagTweets}, state) do
        {myName, serverPID, testServerPID} = state
        # tweets = GenServer.call(serverPID, {:queryHashTagTweet, myName, hashTag})
        if testServerPID == false do
            IO.puts("receive search result")
            #TODO: notify frontEnd
        else
            send testServerPID, {:queryHashTagTweet_result, tagTweets}
        end
        {:noreply, state}
    end

    def handle_cast({:queryMentionTweet_result, mentionTweets}, state) do
        {myName, serverPID, testServerPID} = state
        # tweets = GenServer.call(serverPID, {:queryMentionTweet, myName})
        #TODO notify frontEnd
        if testServerPID == false do
            IO.puts("receive search result")
            #TODO: notify frontEnd
        else
            send testServerPID, {:queryMentionTweet_result, mentionTweets}
        end
        {:noreply, state}
    end

    def handle_cast({:tweetUpdate, name, content}, state) do
        {myName, serverPID, testServerPID} = state
        if testServerPID == false do
            IO.puts("receive update tweet from subscribers: author: " <> name <> " content: " <> content)
            #TODO: notify frontEnd
        else
            send testServerPID, {:receiveTweetUpdate, name, content}
        end
        {:noreply, state}
    end
end