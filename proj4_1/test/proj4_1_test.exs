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

  test "2.server delete account, account will be deleted from ets table" do
    Process.sleep(100)
    # IO.inspect(self())
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    [{name1, pid1}] = :ets.lookup(:namePID, "Cao")
    assert {name1, pid1} = {"Cao", clientPID1}
    GenServer.call(serverPID, {:delete, "Cao"})
    returnPattern = :ets.lookup(:namePID, "Cao")
    assert returnPattern == []
  end

  test "3.client send tweet, tweet exists in ets table" do
    Process.sleep(100)
    # IO.inspect(self())
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    GenServer.cast(clientPID1, {:tweet, "hello world"})
    Process.sleep(50)
    [{_, nameTweets}] = :ets.lookup(:nameTweets, "Cao")
    assert nameTweets == [{"Cao", "hello world"}]
  end

  test "4.client send tweet with hashtag, tweet exists in ets table hashtag catagory" do
    Process.sleep(100)
    # IO.inspect(self())
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    GenServer.cast(clientPID1, {:tweet, "#haha @Cao hello world"})
    Process.sleep(50)
     [{_, tagTweets}] = :ets.lookup(:tagTweets, "haha")
    assert tagTweets == [{"Cao", "#haha @Cao hello world"}]
  end

  test "5.client send retweet, tweet exists in ets table" do
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

  test "6.subscribe to exist account, pair relation exist in ets table" do
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

  test "7.subscribe to non-exist account, pair relation don't exist in ets table" do
    Process.sleep(100)
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    # clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})
    GenServer.call(clientPID1, {:subscribe, "Zheng"})
    [{_, subscribers}] = :ets.lookup(:nameSubscribers, "Cao")
    # assert subscribers == [{"Zheng", clientPID2}]
    # [{_, followers}] = :ets.lookup(:nameFollowers, "Zheng")
    assert subscribers == []
  end

  test "8.client2 send tweet, client1 is connected and receive tweet update from server" do
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

  test "9.client2 send tweet, client1 is not connected and can't receive tweet update from server" do
    Process.sleep(100)
    {:ok, serverPID} = GenServer.start_link(Server, {})
    # IO.inspect(serverPID)
    clientPID1 = GenServer.call(serverPID, {:register, "Cao", self()})
    clientPID2 = GenServer.call(serverPID, {:register, "Zheng", self()})
    GenServer.call(clientPID1, {:subscribe, "Zheng"})
    GenServer.call(serverPID, {:delete, "Cao"})
    # capture child process IO.output, set test_case process as group_leader
    # Process.group_leader(clientPID1, self())
    GenServer.cast(clientPID2, {:tweet, "#haha @Cao hello world"})
    # assert TestFunc.validateUpdateTweet("Zheng", "#haha @Cao hello world") == true
    
    # 
    # assert_receive {:io_request, _, _, {:put_chars, :unicode, "receive update tweet from subscribers: author: Zheng content: #haha @Cao hello world\n"}}
  end

  test "10.client query subscriber tweet from server" do
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

  test "11.client query hashTag tweet from server" do
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

  test "12.client query mention tweet from server" do
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

end
