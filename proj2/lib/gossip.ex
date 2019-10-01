defmodule GossipServer do
    use GenServer

    def init(state) do
        {:ok,state}
    end

    def handle_cast({:start, numNodes, topology}, state) do
        neighbourListID = Topology.getNeighbor(numNodes, topology)
        # may need to round up
        numNodes = length(neighbourListID)
        
        IO.inspect(neighbourListID)

        finishNum = 0
        receiveCount = 0
        startSend = 0
        peerListPair = Enum.map(1..numNodes, fn index -> GenServer.start_link(GossipActor, {self(), receiveCount, startSend}) end)

        #map to id to pid
        neighborListPID = Enum.map(1..numNodes, fn index ->
            subPIDList = Enum.map(Enum.at(neighbourListID, index-1), fn id ->
                pair = Enum.at(peerListPair, id - 1)
                elem(pair, 1)
            end
            )
        end
        )

        # # send neighbourPID
        Enum.map(1..numNodes, fn index -> GenServer.cast(elem(Enum.at(peerListPair, index - 1), 1), {:neighbor, Enum.at(neighborListPID, index - 1)}) end)

        #IO.inspect(neighborListPID)
        randomId = :rand.uniform(numNodes)

        startTime = System.monotonic_time(:millisecond)

        GenServer.cast(elem(Enum.at(peerListPair, randomId - 1), 1), {:rumor, "This is a rumor"})

        #start monitor
        Enum.map(peerListPair, fn pair -> Process.monitor(elem(pair, 1)) end)
        
        {:noreply, {finishNum, numNodes, startTime}}
        
    end

    def handle_info({:DOWN, ref, :process, _, _}, state) do
        {finishNum, numNodes, startTime} = state
        finishNum = finishNum + 1
        if finishNum == numNodes do
            IO.puts("convergence time: " <> Integer.to_string(System.monotonic_time(:millisecond) - startTime))
            Process.exit(self(),:normal)
        end
        {:noreply, {finishNum, numNodes, startTime}}
    end
end

defmodule GossipActor do
    use GenServer

    def init(state) do
        {:ok,state}
    end

    def handle_cast({:neighbor, neighborListPID}, state) do
        {bossid, receiveCount, startSend} = state
        {:noreply, {bossid, receiveCount, startSend, neighborListPID}}
    end

    def handle_cast({:rumor, rumor}, state) do
        # IO.puts(rumor)
        {bossid, receiveCount, startSend, neighborListPID} = state
        receiveCount = receiveCount + 1;
        
        if receiveCount >= 10 do
            IO.puts("finish")
            Process.exit(self(),:normal)
        else
            if startSend == 0 do
                GenServer.cast(self(), {:send, rumor})
            end
        end
        startSend = 1
        {:noreply, {bossid, receiveCount, startSend, neighborListPID}}
        
    end

    def handle_cast({:send, rumor}, state) do
        {bossid, receiveCount, startSend, neighborListPID} = state

        {randomPID, newNeighborListPID} = selectRandomNeighbor(neighborListPID)

        if length(newNeighborListPID) > 0 do
            GenServer.cast(randomPID, {:rumor, rumor})
            GenServer.cast(self(), {:send, rumor})
            Process.sleep(100)
        else
            IO.puts("finish")
            Process.exit(self(),:normal)
        end
        {:noreply,{bossid, receiveCount, startSend, newNeighborListPID}}
    end


    def selectRandomNeighbor(neighborListPID) do
        len = length(neighborListPID)

        if len == 0 do
            {:null, neighborListPID}
        else
            randomIndex = :rand.uniform(len)
            randomPID = Enum.at(neighborListPID, randomIndex - 1)
            if Process.alive?(randomPID) == true do
                {randomPID, neighborListPID}
            else
                neighborListPID = neighborListPID -- [randomPID]
                selectRandomNeighbor(neighborListPID)
            end
        end

    end
end