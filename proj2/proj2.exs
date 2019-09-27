# IO.puts("Initial")

defmodule MyTimer do
    def checkAlive(pid) do
        if Process.alive?(pid) == true do
            checkAlive(pid)
        end
    end
end

numNodes = Enum.at(System.argv, 0) |> String.to_integer()
topology = Enum.at(System.argv, 1)
algorithm = Enum.at(System.argv, 2)


# GossipServer.start(numNodes, topology)

{:ok, gossipServerpid} = GenServer.start_link(GossipServer, {})

GenServer.cast(gossipServerpid, {:start, numNodes, topology})

MyTimer.checkAlive(gossipServerpid)

