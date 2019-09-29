defmodule PushServer do
    use GenServer

    def init(state) do
        {:ok,state}
    end

    def handle_cast({:start, numNodes, topology}, state) do
        neighbourListID = Topology.getNeighbor(numNodes, topology)
        # may need to round up
        numNodes = length(neighbourListID)
        finishNum = 0
        w = 1
        round = 0
        startSend = 0
        peerListPair = Enum.map(1..numNodes, fn s -> GenServer.start_link(PushActor, {self(), s, w, round, startSend}) end)

        #map to id to pid
        neighborListPID = Enum.map(1..numNodes, fn index ->
            subPIDList = Enum.map(Enum.at(neighbourListID, index-1), fn id ->
                pair = Enum.at(peerListPair, id - 1)
                elem(pair, 1)
            end
            )
        end
        )

        IO.inspect(neighbourListID)

        # # send neighbourPID
        Enum.map(1..numNodes, fn index -> GenServer.cast(elem(Enum.at(peerListPair, index - 1), 1), {:neighbor, Enum.at(neighborListPID, index - 1)}) end)

        #IO.inspect(neighborListPID)
        randomId = :rand.uniform(numNodes)

        startTime = System.monotonic_time(:millisecond)

        GenServer.cast(elem(Enum.at(peerListPair, randomId - 1), 1), {:send})

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

defmodule PushActor do
    use GenServer

    def init(state) do
        {:ok,state}
    end

    def handle_cast({:neighbor, neighborListPID}, state) do
        {bossid, s, w, round, startSend} = state
        {:noreply, {bossid, s, w, round, startSend, neighborListPID}}
    end

    def handle_cast({:message, inputS, inputW}, state) do
        # IO.puts(rumor)
        {bossid, s, w, round, startSend, neighborListPID} = state
        oldRatio = s / w
        newS = inputS + s
        newW = inputW + w
        newRatio = newS / newW

        # testOutPut = [newS, newW, newRatio]
        # IO.inspect(self())
        # IO.inspect(testOutPut)

        round = cond do
            abs(newRatio - oldRatio) <= :math.pow(10,-10) ->
                round + 1
            true ->
                0
        end
        # IO.puts(round)

        if round >= 3 do
            IO.puts("finish")
            Process.exit(self(),:normal)
        else
            if startSend == 0 do
                GenServer.cast(self(), {:send})
            end
        end
        startSend = 1
        {:noreply, {bossid, newS, newW, round, startSend, neighborListPID}}
        
    end

    def handle_cast({:send}, state) do
        {bossid, s, w, round, startSend, neighborListPID} = state
        startSend = 1
        {randomPID, newNeighborListPID} = selectRandomNeighbor(neighborListPID)

        if length(newNeighborListPID) > 0 do
            GenServer.cast(randomPID, {:message, s / 2, w / 2})
            GenServer.cast(self(), {:send})
            Process.sleep(20)
        else
            IO.puts("finish")
            Process.exit(self(),:normal)
        end
        {:noreply,{bossid, s / 2, w / 2, round, startSend, newNeighborListPID}}
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