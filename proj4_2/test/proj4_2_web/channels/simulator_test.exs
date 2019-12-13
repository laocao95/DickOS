defmodule Proj42Web.SimulatorTest do
    @endpoint Proj42Web.Endpoint
    use Phoenix.ChannelTest
    use ExUnit.Case

    test "simulator" do
        # two user
        GenServer.call(:server, {:register, "user1"})
        GenServer.call(:server, {:register, "user2"})

        numUser = 100

        accountList = Enum.map(1..numUser, fn i -> 
            name = "user" <> Integer.to_string(i)
            GenServer.call(:server, {:register, name, self()})
            name
          end)
        

        {:ok, socket1} = connect(Proj42Web.UserSocket, %{"user_id" => "user1"}, %{})
        {:ok, _, socket1} = subscribe_and_join(socket1, "room:server:" <> "user1", %{})
        
        
        {:ok, socket2} = connect(Proj42Web.UserSocket, %{"user_id" => "user2"}, %{})
        {:ok, _, socket2} = subscribe_and_join(socket2, "room:server:" <> "user2", %{})

        push(socket1, "subscribe", %{"username" => "user1", "subscribeToName" => "user2"})

        Process.sleep(200)

        IO.inspect(:ets.lookup(:nameSubscribers, "user1"))
    end

  end
  