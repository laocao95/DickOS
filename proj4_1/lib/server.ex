defmodule Server do
    use GenServer

    def init(state) do
        writeActorNum = 16
        searchActorNum = 1
        writeActorIndex = 0
        searchActorIndex = 0
        writeActorPIDList = Enum.map(1..writeActorNum, fn index ->
            {:ok, actorPID} = GenServer.start_link(WriteActor, {})
            actorPID
        end)
        searchActorPIDList = Enum.map(1..searchActorNum, fn index ->
            {:ok, actorPID} = GenServer.start_link(SearchActor, {})
            actorPID
        end)
        children = [
            {Mutex, name: MyMutex}
        ]
        {:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)
        
        opts = [:set, :public, :named_table, write_concurrency: true, read_concurrency: true]
        #name -> [{name, pid}]
        :ets.new(:nameSubscribers, opts)
        #name -> [{name, pid}]
        :ets.new(:nameFollowers, opts)
        #name -> PID
        :ets.new(:namePID, opts)
        #tweetsByName
        :ets.new(:nameTweets, opts)
        #tweetsByTag
        :ets.new(:tagTweets, opts)
        #tweetsByMention
        :ets.new(:mentionTweets, opts)
        {:ok, {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex}}
    end

    #register handler from frontEnd request
    def handle_call({:register, name, testServerPID}, _from, state) do
        {:ok, clientPID} = GenServer.start_link(Client, {name, self(), testServerPID})
        :ets.insert(:namePID, {name, clientPID})
        :ets.insert(:nameSubscribers, {name, []})
        :ets.insert(:nameFollowers, {name, []})
        :ets.insert(:nameTweets, {name, []})
        {:reply, clientPID, state}
    end

    def handle_call({:delete, name}, _from, state) do
        [{_, pid}] = :ets.lookup(:namePID, name)
        :ets.delete(:namePID, name)
        :ets.delete(:nameSubscribers, name)
        :ets.delete(:nameFollowers, name)
        :ets.delete(:nameTweets, name)
        {:reply, state, state}
    end

    #subscribe handler
    def handle_call({:subscribe, name, subscribeToName}, _from, state) do

        #update subscribers
        if :ets.member(:namePID, subscribeToName) == true do
            if name != subscribeToName do
                [{_, subscribeToPID}] = :ets.lookup(:namePID, subscribeToName)
                
                [{_, subscribers}] = :ets.lookup(:nameSubscribers, name)
    
                subscribers = subscribers ++ [{subscribeToName, subscribeToPID}]
    
                # IO.inspect(subscribers)
    
                :ets.insert(:nameSubscribers, {name, subscribers})
    
                #update followers
                [{_, followers}] = :ets.lookup(:nameFollowers, subscribeToName)
                followers = followers ++ [{name, elem(_from, 0)}]
    
                # IO.inspect(followers)
    
                :ets.insert(:nameFollowers, {subscribeToName, followers})
            end 
        end
        {:reply, state, state}
    end
    
    #tweet handler
    def handle_cast({:tweet, name, content}, state) do
        {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex} = state
        GenServer.cast(Enum.at(writeActorPIDList, writeActorIndex), {:tweet, name, content})
        writeActorIndex = writeActorIndex + 1 |> rem(length(writeActorPIDList))
        # Func.tweetHandler(name, content)
        {:noreply, {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex}}
    end

    #retweet handler
    def handle_cast({:retweet, name, tweet}, state) do
        {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex} = state
        {originalName, content} = tweet
        GenServer.cast(Enum.at(writeActorPIDList, writeActorIndex), {:tweet, name, content})
        writeActorIndex = writeActorIndex + 1 |> rem(length(writeActorPIDList))
        # Func.tweetHandler(name, content)
        {:noreply, {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex}}
    end

    #search
    #querySubscriberTweet handler
    def handle_cast({:querySubscriberTweet, name, clientPID}, state) do
        {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex} = state
        GenServer.cast(Enum.at(searchActorPIDList, searchActorIndex), {:querySubscriberTweet, name, clientPID})
        searchActorIndex = searchActorIndex + 1 |> rem(length(searchActorPIDList))
        {:noreply, {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex}}
    end
    
    #queryHashTagTweet handler
    def handle_cast({:queryHashTagTweet, name, clientPID, hashTag}, state) do        
        {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex} = state
        GenServer.cast(Enum.at(searchActorPIDList, searchActorIndex), {:queryHashTagTweet, name, clientPID, hashTag})
        searchActorIndex = searchActorIndex + 1 |> rem(length(searchActorPIDList))
        {:noreply, {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex}}
    end

    #queryMentionTweet handler
    def handle_cast({:queryMentionTweet, name, clientPID}, state) do
        {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex} = state
        GenServer.cast(Enum.at(searchActorPIDList, searchActorIndex), {:queryMentionTweet, name, clientPID})
        searchActorIndex = searchActorIndex + 1 |> rem(length(searchActorPIDList))
        {:noreply, {writeActorPIDList, writeActorIndex, searchActorPIDList, searchActorIndex}}
    end

end
