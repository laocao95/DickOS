#simulator
numUser = Enum.at(System.argv, 0) |> String.to_integer()
numMsg = Enum.at(System.argv, 1) |> String.to_integer()

{:ok, serverPID} = GenServer.start_link(Server, {})
#register accounts
accountList = Enum.map(1..numUser, fn i -> 
  name = "Cao" <> Integer.to_string(i)
  clientPID = GenServer.call(serverPID, {:register, name, self()})
  {name, clientPID}
end)

#these account subscribe each other
Enum.map(accountList, fn {name, clientPID} -> 
  Enum.map(accountList, fn {name2, clientPID2} ->
    GenServer.call(clientPID, {:subscribe, name2})
  end)
end)

# each count send tweets
Enum.map(1..numMsg, fn i ->
  Enum.map(accountList, fn {name, clientPID} ->
    GenServer.cast(clientPID, {:tweet, "hello world!"})
  end)
end)

# Enum.map(accountList, fn {name, clientPID} ->
#   Enum.map(1..1000, fn i ->
#     GenServer.cast(clientPID, {:tweet, "hello world!"})
#   end)
# end)

start_time = System.monotonic_time(:millisecond)
TestFunc.receiveUpdateCount(0, numUser * (numUser - 1) * numMsg)
end_time = System.monotonic_time(:millisecond)
IO.puts("publish and receive all the tweets, total time(millisecond): " <> Integer.to_string(end_time - start_time))


#each account search for tweets
Enum.map(accountList, fn {name, clientPID} -> 
    GenServer.cast(clientPID, {:querySubscriberTweet})
end)
start_time = System.monotonic_time(:millisecond)
TestFunc.receiveSearchCount(0, numUser)
end_time = System.monotonic_time(:millisecond)
IO.puts("search tweets time: " <> Integer.to_string(end_time - start_time))

# Process.sleep(5000)

