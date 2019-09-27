defmodule Topology do
    def full(numNodes) do
        neighborList = 
        for i <- 1..numNodes do
            subList = 
            for j <- 1..numNodes  do
                if (j !== i) do
                    j
                end
            end
            subList=Enum.reject(subList, &is_nil/1)
        end
    end

    def line(numNodes) do
        neighborList = 
        for i <- 1..numNodes do
            subList = 
            cond do
                i == 1 && numNodes > 1 ->
                    nei = i + 1
                    [nei]
                i > 1 && i < numNodes ->
                    nei1 = i - 1
                    nei2 = i + 1
                    [nei1, nei2]
                i == numNodes ->
                    nei = i - 1
                    [nei]
            end            
        end
    end

    def rand2D(numNodes) do
        nodes = 
        for i <- 1..numNodes do
            [i, :rand.uniform(), :rand.uniform()]       # generate nodes
        end
        neighborList = 
        for first <- 1..numNodes do                     # 1st node
            subList = 
            for second <- 1..numNodes do                # 2nd node
                dist = distance(Enum.at(nodes, first - 1), Enum.at(nodes, second - 1))  # get node distance
                if first != second && dist <= 0.1 do
                    second                              # add nodes
                end
            end
            subList=Enum.reject(subList, &is_nil/1)     # delete nil nodes
        end
    end

    # def torus3D(numNodes) do
    #     num = ceil(:math.pow(numNodes, 1 / 3))          # rounded cube side length
    #     for x <- 1..num, y <- 1..num, z <- 1..num do
            
    #     end
    # end

    def getNeighbor(numNodes, topology) do
        cond do
            topology == "full" ->
                Topology.full(numNodes)
            topology == "line" ->
                Topology.line(numNodes)
            topology == "rand2D" ->
                Topology.rand2D(numNodes)
            # topology == "3Dtorus" ->
            #     Topology.torus3D(numNodes)
        end
    end

    def distance(node1, node2) do
        dx = Enum.at(node1, 1) - Enum.at(node2, 1)
        dy = Enum.at(node1, 2) - Enum.at(node2, 2)
        dis = :math.sqrt(dx * dx + dy * dy)
        dis
    end

    # def getNum(x, y, z, num) do
    #     trunc(x + )
    # end

end


# IO.inspect(Topology.getNeighbor(20, "3Dtorus"))