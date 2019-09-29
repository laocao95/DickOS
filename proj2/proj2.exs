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

{:ok, serverpid} = cond do
    algorithm == "gossip" ->
        GenServer.start_link(GossipServer, {})
    algorithm == "push-sum" ->
        GenServer.start_link(PushServer, {})
    true ->
        IO.puts("error input")
        Process.exit(self(), :normal)
end

GenServer.cast(serverpid, {:start, numNodes, topology})

MyTimer.checkAlive(serverpid)