defmodule StartServer do
    use GenServer

    def init(state) do
        {:ok,state}
    end

    def handle_cast({:start, numNodes, numRequests}, state) do
        actorPairList = Enum.map(1..numNodes, fn index -> 
            # coordinate for choosing closest k
            coordinateX = :rand.uniform(numNodes)
            coordinateY = :rand.uniform(numNodes)
            # node_id
            nodeId = :crypto.hash(:sha, Integer.to_string(index)) |> Base.encode16()
            initialEmptyTable = Enum.map(1..10, fn i -> [] end) #intialize with 10 level
            {:ok, actorPID} = GenServer.start_link(Actor, {coordinateX, coordinateY, nodeId, initialEmptyTable, :null}) 
            {nodeId, actorPID}
        end)

        GenServer.cast(self(), {:insert_process})
        {:noreply, {numNodes, numRequests, actorPairList, [], 0, 0, 0}}

    end

    def handle_cast({:insert_process}, state) do
        {numNodes, numRequests, notFinishPairList, finishPairList, successCount, failCount, maxHop} = state

        if length(notFinishPairList) == 0 do
            GenServer.cast(self(), {:publish})
            #table test
            # Enum.map(finishPairList, fn {nodeId, nodePID} ->
            #     table = GenServer.call(nodePID, {:getNeighborTable})
            #     IO.puts(nodeId)
            #     IO.inspect(table)
            # end)
            # Process.exit(self(),:normal)
            {:noreply, state}
        else
            [actorPIDPair | notFinishPairList] = notFinishPairList  
            GenServer.call(elem(actorPIDPair, 1), {:insert, finishPairList}, :infinity) #sychronize, wait until update the neighbor table   
            finishPairList = [actorPIDPair | finishPairList]
            GenServer.cast(self(),{:insert_process})
            {:noreply, {numNodes, numRequests, notFinishPairList, finishPairList, successCount, failCount, maxHop}}
        end
        
    end

    def handle_cast({:publish}, state) do
        {numNodes, numRequests, notFinishPairList, finishPairList, successCount, failCount, maxHop} = state
        gatePID = elem(Enum.at(finishPairList, :rand.uniform(length(finishPairList)) - 1), 1) #random gate
        objectId = :crypto.hash(:sha, Integer.to_string(100000)) |> Base.encode16()
        serverPID = self()
        objectLocation = {objectId, serverPID}
        Func.publishBySurrogateRouting(gatePID, objectLocation, 1) #start from level 1 of gate
        GenServer.cast(self(), {:request_process, objectId}) #enter request state
        {:noreply, state}
    end

    def handle_cast({:request_process, objectId}, state) do
        {numNodes, numRequests, notFinishPairList, finishPairList, successCount, failCount, maxHop} = state
        # Enum.map(finishPairList, fn {nodeId, nodePID} ->
        #     table = GenServer.call(nodePID, {:getNeighborTable})
        #     storage = GenServer.call(nodePID, {:getStorage})
        #     IO.puts(nodeId)
        #     IO.inspect(storage)
        #     IO.inspect(table)
        # end)

        Func.startTimer(finishPairList, numRequests, objectId, 0)
        # Process.exit(self(),:normal)
        {:noreply, state}
    end

    def handle_cast({:result, res, hop}, state) do
        {numNodes, numRequests, notFinishPairList, finishPairList, successCount, failCount, maxHop} = state
        maxHop = max(hop, maxHop)
        successCount = if res == :success do
            IO.puts("success, hop " <> Integer.to_string(hop))
            successCount + 1
        else
            successCount
        end
        failCount = if res == :fail do
            IO.puts("fail, hop " <> Integer.to_string(hop))
            failCount + 1
        else
            failCount
        end
        if successCount + failCount == numRequests * length(finishPairList) do
            IO.puts(maxHop)
            Process.exit(self(), :normal)
        end
        {:noreply, {numNodes, numRequests, notFinishPairList, finishPairList, successCount, failCount, maxHop}}
    end

end


defmodule Actor do
    use GenServer

    def init(state) do
        {:ok,state}
    end

    #surrogate routing
    def handle_cast({:request, objectId, level, hop, mainPID}, state) do
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state

        if  objectLocation != :null do
            #find the object
            GenServer.cast(mainPID, {:result, :success, hop})
            IO.inspect(mainPID)
            {:noreply, state}
        else
            #find the nexthop
            if length(neighborTable) < level do
                #fail to find
                GenServer.cast(mainPID, {:result, :fail, hop})
                {:noreply, state}
            else
                levelNeighborTable = neighborTable |> Enum.at(level - 1) |> List.flatten() #check has neighbor in this level
                if length(levelNeighborTable) == 0 do
                    GenServer.cast(mainPID, {:result, :fail, hop})
                    {:noreply, state}
                else # has neighbor in this level
                    d = String.at(objectId, level - 1) |> Integer.parse(16) |> elem(0)
                    e = neighborTable |> Enum.at(level - 1) |> Enum.at(d) |> Enum.at(0)  #get the closest in slot
                    e = if e == nil do
                        Func.nexthopLoop(level, neighborTable, d)
                    else
                        e
                    end
                    GenServer.cast(elem(e, 1), {:request, objectId, level + 1, hop + 1, mainPID})
                    {:noreply, state}
                end
            end
        end
    end

    def handle_call({:insert, finishPairList}, _from, state) do
        # IO.inspect(state)
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state
        if length(finishPairList) > 0 do
            # IO.puts("enter3")
            gatePID = elem(Enum.at(finishPairList, :rand.uniform(length(finishPairList)) - 1), 1) #random gate
            {surrogateId, surrogatePID} = Func.findSurrogate(gatePID, nodeId, 1) #start from level 1 of gate
            newNeighborTable = Func.acquireNeighborTable(nodeId, self(), surrogateId, surrogatePID) #acquire neighbourTable
            # IO.puts(surrogateId)
            # IO.inspect(surrogatePID)
            state = {coordinateX, coordinateY, nodeId, newNeighborTable, objectLocation}
            {:reply, state, state}
        else
            # IO.puts("enter4")
            {:reply, state, state}
        end
        
    end

    #surrogate routing
    def handle_call({:nexthop, target, level}, _from, state) do
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state
        #if publish, objectId is targetId
        targetId = case target do
            {objectId, serverPID} ->        
                objectId
            x ->
                target
        end
        #if publish, update state
        state = case target do
            {objectId, serverPID} ->        
                {coordinateX, coordinateY, nodeId, neighborTable, {objectId, serverPID}}
            x ->
                state
        end

        if length(neighborTable) < level do
            {:reply, {:finish, nodeId, self()}, state}
        else
            levelNeighborTable = neighborTable |> Enum.at(level - 1) |> List.flatten() #check has neighbor in this level
            if length(levelNeighborTable) == 0 do
                {:reply, {:finish, nodeId, self()}, state}
            else # has neighbor in this level
                d = String.at(targetId, level - 1) |> Integer.parse(16) |> elem(0)
                e = neighborTable |> Enum.at(level - 1) |> Enum.at(d) |> Enum.at(0)  #get the closest in slot
                e = if e == nil do
                    Func.nexthopLoop(level, neighborTable, d)
                else
                    e
                end
                {:reply, {:notfinish, elem(e, 0), elem(e, 1)}, state}
            end
        end
    end

    def handle_call({:acknowledged, prefix}, _from, state) do
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state
        neighborList = Func.getMatchingNeighbor(nodeId, prefix, neighborTable)
        if length(neighborList) == 0 do
            # only node with prefix
            {:reply, {:only, [{nodeId, self()}]}, state}
        else
            # recursive multicast
            {:reply, {:notonly, neighborList}, state}
        end
    end

    def handle_call({:getNeighbor, level}, _from, state) do
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state
        levelNeighborList = Enum.at(neighborTable, level - 1)
        {:reply, levelNeighborList, state}
    end

    def handle_call({:newNode, newNodeId, newNodePID}, _from, state) do
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state

        # IO.puts("get new node")
        alpha = Func.greatestCommonPrefix(newNodeId, nodeId, 0)
        len = String.length(alpha) #level should put in
        newLevelNeighborList = Func.updateClosestK(len, newNodeId, newNodePID, coordinateX, coordinateY, Enum.at(neighborTable, len))
        # List.update_at(newLevelNeighborList, slotIndex, [{newNodeId, newNodePID}])
        newNeighborTable = Func.updateListByIndex(neighborTable, len, newLevelNeighborList)
        state = {coordinateX, coordinateY, nodeId, newNeighborTable, objectLocation}
        {:reply, state, state}
    end

    def handle_call({:getCoordinate}, _from, state) do
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state
        {:reply, {coordinateX, coordinateY}, state}
    end

    def handle_call({:getNeighborTable}, _from, state) do
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state
        {:reply, neighborTable, state}
    end

    def handle_call({:getStorage}, _from, state) do
        {coordinateX, coordinateY, nodeId, neighborTable, objectLocation} = state
        {:reply, objectLocation, state}
    end

end

defmodule Func do
    def startTimer(finishPairList, numsRequest, objectId, count) do
        IO.puts("enter timer")
        if count < numsRequest do
            IO.puts("timer end")
            Enum.map(finishPairList, fn {nodeId, nodePID} ->
                GenServer.cast(nodePID, {:request, objectId, 1, 0, self()}) #start search from level 1, hop 0
            end)
            Process.sleep(1000)
            startTimer(finishPairList, numsRequest, objectId, count + 1)
        end
    end

    def findSurrogate(gatePID, targetId, level) do
        return_pattern = GenServer.call(gatePID, {:nexthop, targetId, level})
        case return_pattern do
            {:finish, nodeId, nodePID} ->
                {nodeId, nodePID}
            {:notfinish, nodeId, nodePID} ->
                findSurrogate(nodePID, targetId, level + 1)
        end
    end

    def publishBySurrogateRouting(gatePID, objectLocation, level) do
        {objectId, serverPID} = objectLocation
        return_pattern = GenServer.call(gatePID, {:nexthop, objectLocation, level})
        case return_pattern do
            {:finish, nodeId, nodePID} ->
                {nodeId, nodePID}
            {:notfinish, nodeId, nodePID} ->
                publishBySurrogateRouting(nodePID, objectLocation, level + 1)
        end
    end    

    def nexthopLoop(level, neighborList, d) do
        d = d + 1 |> rem(16)
        e = neighborList |> Enum.at(level - 1) |> Enum.at(d) |> Enum.at(0)  #get the closest in slot
        if e == nil do
            nexthopLoop(level, neighborList, d)
        else
            e
        end
    end

    def acquireNeighborTable(nodeId, nodePID, surrogateId, surrogatePID) do
        prefix = Func.greatestCommonPrefix(nodeId, surrogateId, 0)
        maxLevel = String.length(prefix) + 1       # the lowest level is #1
        maxLevelList = Func.acknowledgedMulticast(prefix, nodeId, nodePID, surrogateId, surrogatePID)
        # IO.puts("max level " <> Integer.to_string(maxLevel))
        # IO.inspect(maxLevelList)
        #add pre empty level
        neighborTable = if maxLevel < 10 do
            Enum.map(1..10 - maxLevel, fn i -> [] end)
        else
            []
        end
        #IO.inspect(neighborTable)

        if length(maxLevelList) > 0 do
            neighborTable = Func.getNextListLoop(neighborTable, maxLevelList, maxLevel, nodeId, nodePID)
            if length(neighborTable) < 10 do
                emptyTable = Enum.map(1..10 - length(neighborTable), fn i -> [] end)
                neighborTable = neighborTable ++ emptyTable
                neighborTable |> Enum.reverse()
            else
                neighborTable |> Enum.reverse()
            end

        else
            Enum.map(1..10, fn i -> [] end)
        end

    end

    def acknowledgedMulticast(prefix, nodeId, nodePID, surrogateId, surrogatePID) do
        IO.puts("acknowledge loop")
        return_pattern = if surrogatePID != self() do
            GenServer.call(surrogatePID, {:acknowledged, prefix})
        else
            {:end}
        end
        
        # IO.inspect(return_pattern)
        len = String.length(prefix)
        # IO.puts(len)
        case return_pattern do
            {:end} ->
                []
            {:only, neighborList} ->
                #recursive bottom
                [{neighborId, neighborPID}] = neighborList
                GenServer.call(neighborPID, {:newNode, nodeId, nodePID})
                neighborList
            {:notonly, neighborList} ->
                newNeighborList = Enum.map(neighborList, fn {surrogateId, surrogatePID} -> 
                    newprefix = String.slice(surrogateId, 0..len)
                    acknowledgedMulticast(newprefix, nodeId, nodePID, surrogateId, surrogatePID)
                end)
                newNeighborList |> List.flatten()
        end
    end

    def getMatchingNeighbor(myId, prefix, neighborTable) do
        alpha = Func.greatestCommonPrefix(myId, prefix, 0)
        startIndex = String.length(alpha)
        neighborTable |> Enum.slice(startIndex..-1) |> List.flatten()
        # List.flatten(neighborList)
        # neighborList = Enum.slice(neighborList, startIndex..-1) |> Enum.filter(fn x -> length(x) > 0 end) #filter the empty level

        # neighborList = for n <- 0..length(neighborList)-1, do:
        #     levelList = Enum.at(neighborList, n) |> Enum.filter(fn x -> length(x) > 0 end)
        # end #filter the empty slot
    end

    def getNextListLoop(resTable, elementList, level, nodeId, nodePID) do
        IO.puts("next list loop")
        #keepClosestK and put into slot
        # IO.puts("enter nextListLoop")
        # IO.puts(level)
        initialLevelTable = Enum.map(0..15, fn i -> [] end)
        levelTable = Func.putElementIntoSlot(initialLevelTable, elementList, level - 1)
        resTable = resTable ++ [levelTable]
        nextList = Func.getNextList(elementList, level - 1, nodeId, nodePID)
        if length(nextList) > 0 do
            getNextListLoop(resTable, nextList, level - 1, nodeId, nodePID)
        else
            resTable
        end

    end

    def getNextList(levelNeighborList, level, nodeId, nodePID) do

        if level > 0 do
            # IO.puts("enter1")
            newList = Enum.map(levelNeighborList, fn {neighborId, neighborPID} -> 
                sublist = GenServer.call(neighborPID, {:getNeighbor, level}) #get sublist
                #notify these neighbor
                #Enum.map(sublist, fn {id, pid} -> GenServer.call(neighborPID, {:newNode, nodeId, nodePID}) end)
                GenServer.call(neighborPID, {:newNode, nodeId, nodePID})
                sublist
            end)
            newList |> List.flatten() |> Enum.uniq()
        else
            # IO.puts("enter12")
            []
        end
    end

    #temporarily insert into it
    def updateClosestK(len, newNodeId, newNodePID, coordinateX, coordinateY, levelNeighborList) do
        #{neighborX, neighborY} = GenServer.call()
        if length(levelNeighborList) == 0 do
            newLevelNeighborList = Enum.map(0..15, fn i -> [] end)
            slotIndex = String.at(newNodeId, len) |> Integer.parse(16) |> elem(0)
            Func.updateListByIndex(newLevelNeighborList, slotIndex, [{newNodeId, newNodePID}])
        else
            slotIndex = String.at(newNodeId, len) |> Integer.parse(16) |> elem(0)
            Func.updateListByIndex(levelNeighborList, slotIndex, Enum.at(levelNeighborList, slotIndex) ++ [{newNodeId, newNodePID}] |> Enum.uniq())
        end

    end

    #valid
    def putElementIntoSlot(levelTable, elementList, lookAtIndex) do
        putElementIntoSlotLoop(levelTable, elementList, lookAtIndex, 0)
    end

    def putElementIntoSlotLoop(levelTable, elementList, lookAtIndex, index) do
        if index >= length(elementList) do
            levelTable
        else
            slotIndex = Enum.at(elementList, index) |> elem(0) |> String.at(lookAtIndex) |> Integer.parse(16) |> elem(0)
            newLevelTable = Func.updateListByIndex(levelTable, slotIndex, Enum.at(levelTable, slotIndex) ++ [Enum.at(elementList, index)])
            putElementIntoSlotLoop(newLevelTable, elementList, lookAtIndex, index + 1)
        end
    end

    def greatestCommonPrefix(id1, id2, index) do
        if String.length(id1) <= index or String.length(id2) <= index do
            if (index == 0) do
                ""
            else
                String.slice(id1, 0..index - 1)
            end
        else
            if String.at(id1, index) == String.at(id2, index) do
                greatestCommonPrefix(id1, id2, index + 1)
            else
                if (index == 0) do
                    ""
                else
                    String.slice(id1, 0..index - 1)
                end
            end
        end
    end

    def updateListByIndex(list, index, newElement) do
        {front, [_ | tail]} = Enum.split(list, index)
        front ++ [newElement | tail]
    end
end