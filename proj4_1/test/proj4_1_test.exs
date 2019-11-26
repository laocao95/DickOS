defmodule Proj4_1Test do
  use ExUnit.Case
  # doctest Proj4_1

  # Functional test
  test "1.server register account, account exists in server's memory, spawn client pid with state {name, serverPID}" do
    Process.sleep(100)
    # IO.inspect(self())
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    [{name1, pid1}] = :ets.lookup(:namePID, "Cao")
    assert {name1, pid1} = {"Cao", clientPID1}
    assert :sys.get_state(clientPID1) == {"Cao", serverPID, self()}
  end

  test "2.client send tweet, tweet exists in server's memory" do
    Process.sleep(100)
    # IO.inspect(self())
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    GenServer.cast(clientPID1, {:tweet, "#haha @Cao hello world"})
    Process.sleep(50)
    [{_, nameTweets}] = :ets.lookup(:nameTweets, "Cao")
    assert nameTweets == [{"Cao", "#haha @Cao hello world"}]
  end

  test "3.client send retweet, tweet exists in server's memory" do
    Process.sleep(100)
    # IO.inspect(self())
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})
    GenServer.cast(clientPID1, {:tweet, "#haha @Cao hello world"})
    Process.sleep(50)
    [{_, nameTweets}] = :ets.lookup(:nameTweets, "Cao")
    GenServer.cast(clientPID2, {:retweet, Enum.at(nameTweets, 0)})
    Process.sleep(50)
    [{_, nameTweets}] = :ets.lookup(:nameTweets, "Zheng")
    assert nameTweets == [{"Zheng", "#haha @Cao hello world"}]
  end

  test "4.subscribe, pair relation exist in server's memory" do
    Process.sleep(100)
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})
    GenServer.call(clientPID1, {:subscribe, "Zheng"})
    [{_, subscribers}] = :ets.lookup(:nameSubscribers, "Cao")
    assert subscribers == [{"Zheng", clientPID2}]
    [{_, followers}] = :ets.lookup(:nameFollowers, "Zheng")
    assert followers == [{"Cao", clientPID1}]
  end

  test "5.client2 send tweet, client1 receive tweet update from server" do
    Process.sleep(100)
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})
    GenServer.call(clientPID1, {:subscribe, "Zheng"})

    #capture child process IO.output, set test_case process as group_leader
    # Process.group_leader(clientPID1, self())
    GenServer.cast(clientPID2, {:tweet, "#haha @Cao hello world"})
    assert TestFunc.validateUpdateTweet("Zheng", "#haha @Cao hello world") == true
    # assert_receive {:io_request, _, _, {:put_chars, :unicode, "receive update tweet from subscribers: author: Zheng content: #haha @Cao hello world\n"}}
  end

  test "6.client query subscriber tweet from server" do
    Process.sleep(100)
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})
    GenServer.call(clientPID1, {:subscribe, "Zheng"})
    GenServer.cast(clientPID2, {:tweet, "#haha @Cao hello world"})
    Process.sleep(50)
    GenServer.cast(clientPID1, {:querySubscriberTweet})
    # tweets = GenServer.call(clientPID1, {:querySubscriberTweet})
    # assert tweets == [{"Zheng", "#haha @Cao hello world"}]
    assert TestFunc.validateSearchResult([{"Zheng", "#haha @Cao hello world"}]) == true
  end

  test "7.client query hashTag tweet from server" do
    Process.sleep(100)
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})
    GenServer.call(clientPID1, {:subscribe, "Zheng"})
    GenServer.cast(clientPID2, {:tweet, "#haha @Cao hello world"})
    Process.sleep(50)
    # tweets = GenServer.call(clientPID1, {:queryHashTagTweet, "haha"})
    GenServer.cast(clientPID1, {:queryHashTagTweet, "haha"})
    # assert tweets == [{"Zheng", "#haha @Cao hello world"}]
    assert TestFunc.validateSearchResult([{"Zheng", "#haha @Cao hello world"}]) == true
  end

  test "8.client query mention tweet from server" do
    Process.sleep(100)
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})
    GenServer.call(clientPID1, {:subscribe, "Zheng"})
    GenServer.cast(clientPID2, {:tweet, "#haha @Cao hello world"})
    Process.sleep(50)
    # tweets = GenServer.call(clientPID1, {:queryMentionTweet})
    # assert tweets == [{"Zheng", "#haha @Cao hello world"}]
    GenServer.cast(clientPID1, {:queryMentionTweet})
    assert TestFunc.validateSearchResult([{"Zheng", "#haha @Cao hello world"}]) == true
  end

  # test "9.performance test. client1 send 2000 tweets and client2 receive 2000 tweet updates." do
  #   Process.sleep(100)

  # end

  # test "10.performance test. client1 send 2000 tweets. 1000 of them contains hashTag #test, client2 search tweets with #test" do
  #   Process.sleep(100)
  #   {:ok, serverPID} = GenServer.start_link(Server, {})
  #   # IO.inspect(serverPID)
  #   # clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
  #   # clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})

  #   #register 10 accounts
  #   accountList = Enum.map(1..10, fn i -> 
  #     name = "Cao" <> Integer.to_string(i)
  #     clientPID = GenServer.call(serverPID, {:register, name, self()})
  #     {name, clientPID}
  #   end)

  #   #these account subscribe each other
  #   Enum.map(accountList, fn {name, clientPID} -> 
  #     Enum.map(accountList, fn {name2, clientPID2} ->
  #       GenServer.call(clientPID, {:subscribe, name2})
  #     end)
  #   end)

  #   # each account send 1000 tweets
  #   Enum.map(1..1000, fn i ->
  #     Enum.map(accountList, fn {name, clientPID} ->
  #       GenServer.cast(clientPID, {:tweet, "hello world!"})
  #     end)
  #   end)
    
    
  #   #each aacount search for tweets
  #   Process.sleep(3000)
  #   Enum.map(accountList, fn {name, clientPID} -> 
  #     GenServer.cast(clientPID, {:querySubscriberTweet})
  #   end)
  #   start_time = System.monotonic_time(:millisecond)
  #   TestFunc.receiveSearchCount(0, 10)
  #   end_time = System.monotonic_time(:millisecond)
  #   IO.puts("search tweets time: " <> Integer.to_string(end_time - start_time))
    
  # end

end
