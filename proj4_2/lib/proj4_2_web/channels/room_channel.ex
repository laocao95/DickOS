defmodule Proj42Web.RoomChannel do
    use Phoenix.Channel
  

    def join("room:" <> _roomId, _params, socket) do
    #   {:error, %{reason: "unauthorized"}}
      {:ok, socket}
    end

    def join("room:server:" <> _roomId, _params, socket) do
        {:ok, socket}
    end

    #join to my subscribers channel
    def handle_in("join_subscribers_channel", params, socket) do
        GenServer.call(:server, {:get_subscribers, params["username"]})
        {:noreply, socket}
    end

    #broadcast channel
    def handle_in("broadcast_tweet", params, socket) do
        tweet = %{name: params["username"], content: params["content"]}
        broadcast!(socket, "broadcast_tweet", %{content: [tweet]})
        {:noreply, socket}
    end
    
    #server channel
    def handle_in("tweet", params, socket) do
        GenServer.cast(:server, {:tweet, params["username"], params["content"]})
        {:noreply, socket}
    end

    def handle_in("register", params, socket) do
        GenServer.call(:server, {:register, params["username"]})
        {:noreply, socket}
    end

    def handle_in("subscribe", params, socket) do
        GenServer.call(:server, {:subscribe, params["username"], params["subscribeToName"]})
        {:noreply, socket}
    end

    def handle_in("search_hashtag", params, socket) do
        GenServer.cast(:server, {:queryHashTagTweet, params["username"], self(), params["hashtag"]})
        {:noreply, socket}
    end

    def handle_in("search_mention", params, socket) do
        GenServer.cast(:server, {:queryMentionTweet, params["username"], self()})
        {:noreply, socket}
    end

    def handle_in("search_subscriber_tweet", params, socket) do
        GenServer.cast(:server, {:querySubscriberTweet, params["username"], self()})
        {:noreply, socket}
    end

    def handle_in("retweet", params, socket) do
        oldTweet = params["content"]
        newTweet = %{name: params["username"], content: oldTweet["content"]}
        GenServer.cast(:server, {:retweet, params["username"], {oldTweet["name"], oldTweet["content"]}})  
        {:noreply, socket}
    end

    def handle_info({:register_successfully}, socket) do
        push socket, "register_successfully", %{}
        {:noreply, socket}
    end

    def handle_info({:subscribe_successfully}, socket) do
        push socket, "subscribe_successfully", %{}
        {:noreply, socket}
    end

    def handle_info({:subscribers, subscribers}, socket) do
        push socket, "subscribers", %{content: subscribers}
        {:noreply, socket}
    end

    def handle_info({:queryHashTagTweet_result, tagTweets}, socket) do
        tagTweets = Enum.map(tagTweets, fn {name, content} ->
            %{name: name, content: content}
        end)
        push socket, "queryHashTagTweet_result", %{content: tagTweets}
        {:noreply, socket}
    end

    def handle_info({:queryMentionTweet_result, mentionTweets}, socket) do
        mentionTweets = Enum.map(mentionTweets, fn {name, content} ->
            %{name: name, content: content}
        end)
        push socket, "queryMentionTweet_result", %{content: mentionTweets}
        {:noreply, socket}
    end
    
    def handle_info({:querySubscriberTweet_result, tweets}, socket) do
        tweets = Enum.map(tweets, fn {name, content} ->
            %{name: name, content: content}
        end)
        push socket, "querySubscriberTweet_result", %{content: tweets}
        {:noreply, socket}
    end
end