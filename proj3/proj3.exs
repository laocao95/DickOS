defmodule MyTimer do
    def checkAlive(pid) do
        if Process.alive?(pid) == true do
            checkAlive(pid)
        end
    end
end

numNodes = Enum.at(System.argv, 0) |> String.to_integer()

numRequests = Enum.at(System.argv, 1) |> String.to_integer()

{:ok, serverpid} = GenServer.start_link(StartServer, {})

IO.inspect(self())

GenServer.cast(serverpid, {:start, numNodes, numRequests})


MyTimer.checkAlive(serverpid)

# Process.sleep(5000)

