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

    def torus3D(numNodes) do
        num = ceil(:math.pow(numNodes, 1 / 3))          # rounded cube side length
        for z <- 1..num, y <- 1..num,  x <- 1..num do
            up = 
            if z == num do
                [getNum(x, y, 1, num)]
            else
                [getNum(x, y, z + 1, num)]
            end
            down = 
            if z == 1 do
                [getNum(x, y, num, num)]
            else
                [getNum(x, y, z - 1, num)]
            end
            left = 
            if x == 1 do
                [getNum(num, y, z, num)]
            else
                [getNum(x - 1, y, z, num)]
            end
            right = 
            if x == num do
                [getNum(1, y, z, num)]
            else
                [getNum(x + 1, y, z, num)]
            end
            front = 
            if y == 1 do
                [getNum(x, num, z, num)]
            else
                [getNum(x, y - 1, z, num)]
            end
            back = 
            if y == num do
                [getNum(x, 1, z, num)]
            else
                [getNum(x, y + 1, z, num)]
            end
            if num == 1 do
                neighbors = []
            else
                neighbors = up ++ down ++ left ++ right ++ front ++ back
            end
        end
    end

    def honeyComb(numNodes) do
        outLevel = ceil(:math.pow(numNodes / 6, 1 / 2))
        numCeil = 6 * outLevel * outLevel # rounded node number
        neighborList = 
        for num <- 1..numCeil do
            level = floor(:math.pow((num - 1) / 6, 1 / 2))
            levelIndex = num - 6 * level * level                 # the index of num in this level
            levelEnd = 6 * (level + 1) * (level + 1)            # the index of the last element in the level
            levelStart = 6 * level * level                      # the index of the last element in last level
            numPerGroup = 2 * (level + 1) - 1
            groupNum = ceil(levelIndex / numPerGroup)
            groupIndex = levelIndex - numPerGroup * (groupNum - 1)
            
            next =                                               # next one in same level
            if num == levelEnd do
                [levelStart + 1]
            else
                [num + 1]
            end

            last = 
            if num == levelStart + 1 do
                [levelEnd]
            else
                [num - 1]
            end

            between = 
            if rem(groupIndex, 2) != 0 do
                if level + 1 == outLevel do               # num in the outest level
                    []
                else
                    [getHoney(level + 2, groupNum, groupIndex + 1)]     # outside
                end
            else
                [getHoney(level, groupNum, groupIndex - 1)]         # inside
            end

            neighborList = [next] ++ [last] ++ [between]
        end
    end

    def getNeighbor(numNodes, topology) do
        cond do
            topology == "full" ->
                Topology.full(numNodes)
            topology == "line" ->
                Topology.line(numNodes)
            topology == "rand2D" ->
                Topology.rand2D(numNodes)
            topology == "3Dtorus" ->
                Topology.torus3D(numNodes)
            topology == "honeycomb" ->
                Topology.honeyComb(numNodes)
        end
    end

    def distance(node1, node2) do
        dx = Enum.at(node1, 1) - Enum.at(node2, 1)
        dy = Enum.at(node1, 2) - Enum.at(node2, 2)
        dis = :math.sqrt(dx * dx + dy * dy)
        dis
    end

    def getNum(x, y, z, num) do
        x + (y - 1) * num + (z - 1) * num * num
    end

    def getHoney(x, y, z) do
        6 * (x - 1) * (x - 1) + (y - 1) * (2 * x - 1) + z
    end
end


IO.inspect(Topology.getNeighbor(12, "honeycomb"))