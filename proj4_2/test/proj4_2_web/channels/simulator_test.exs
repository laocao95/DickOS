defmodule Proj42Web.SimulatorTest do
    @endpoint Proj42Web.Endpoint
    use Phoenix.ChannelTest
    use ExUnit.Case

    test "Simulator" do
        numUser = 200

        userList = Enum.map(1..numUser, fn i -> 
            name = "user" <> Integer.to_string(i)
            GenServer.call(:server, {:register, name})
            {:ok, socket} = connect(Proj42Web.UserSocket, %{"user_id" => name}, %{})
            {:ok, _, socket} = subscribe_and_join(socket, "room:server:" <> name, %{})
            {name, socket}
        end)

        #push subscribe message to user1 channel that make it to subscribe all the other users
        {username1, socket1} = Enum.at(userList, 0)
        
        Enum.map(userList, fn {name, socket} -> 
            push(socket1, "subscribe", %{"username" => username1, "subscribeToName" => name})
        end)

        #wait for storage server handle register request
        Process.sleep(1000)

        #check memory storage that have subscribed all the other users
        [{_, subscribers}] = :ets.lookup(:nameSubscribers, username1)
        assert length(subscribers) == numUser - 1
        
        #each user send a tweets
        Enum.map(userList, fn {name, socket} -> 
            push(socket, "tweet", %{"username" => name, "content" => "testTweet #DOS"})
        end)

        #wait for storage server handle tweet request
        Process.sleep(1000)

        #search to check memory storage that all tweets
        push(socket1, "search_subscriber_tweet", %{"username" => username1})

        GenServer.cast(:server, {:querySubscriberTweet, username1, self()})
        receive do
            {:querySubscriberTweet_result, tweets} ->
                assert length(tweets) == numUser - 1
        end

        # {:ok, socket2} = connect(Proj42Web.UserSocket, %{"user_id" => "user2"}, %{})
        # {:ok, _, socket2} = subscribe_and_join(socket2, "room:server:" <> "user2", %{})
        # push(socket1, "subscribe", %{"username" => "user1", "subscribeToName" => "user2"})
        # Process.sleep(200)
        # IO.inspect(:ets.lookup(:nameSubscribers, "user1"))
    end

  end
  