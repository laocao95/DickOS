defmodule WriteActor do
    use GenServer

    def init(state) do
        #state = {myName, serverPID}
        {:ok, state}
    end

    def handle_cast({:tweet, name, content}, state) do
        #update nameTweets
        resource_id = {NameTweet, name}
        lock = Mutex.await(MyMutex, resource_id)
        #use mutex to make operation atom
        [{_, nameTweets}] = :ets.lookup(:nameTweets, name)
        nameTweets = nameTweets ++ [{name, content}]
        :ets.insert(:nameTweets, {name, nameTweets})
        Mutex.release(MyMutex, lock)
        
        #update tagTweets
        tagList = Regex.scan(~r/(^#|\s#)([A-Za-z0-9_]+)(?=$|\s)/, content)
        tagList = Enum.map(tagList, fn item -> Enum.at(item, 2) end)
        for tag <- tagList do
            resource_id = {Tag, tag}
            lock = Mutex.await(MyMutex, resource_id)
            #use mutex to make operation atom
            tagTweets = case :ets.lookup(:tagTweets, tag) do
                [{_, tagTweets}] ->
                    tagTweets ++ [{name, content}]
                [] ->
                    [{name, content}]
            end
            :ets.insert(:tagTweets, {tag, tagTweets})
            Mutex.release(MyMutex, lock)
        end
        #update mentionTweets
        mentionList = Regex.scan(~r/(^@|\s@)([A-Za-z0-9_]+)(?=$|\s)/, content)
        mentionList = Enum.map(mentionList, fn item -> Enum.at(item, 2) end)        
        for mention <- mentionList do
            resource_id = {Mention, mention}
            lock = Mutex.await(MyMutex, resource_id)
            #use mutex to make operation atom
            mentionTweets = case :ets.lookup(:mentionTweets, mention) do
                [{_, mentionTweets}] ->
                    mentionTweets ++ [{name, content}]
                [] ->
                    [{name, content}]
            end
            :ets.insert(:mentionTweets, {mention, mentionTweets})
            Mutex.release(MyMutex, lock)
        end
        
        #dispatch
        [{_, followers}] = :ets.lookup(:nameFollowers, name)
        # IO.inspect(followers)
        for {followerName, followerPID} <- followers do
            if Process.alive?(followerPID) do
                GenServer.cast(followerPID, {:tweetUpdate, name, content})
            end
        end
        {:noreply, state}
    end
end