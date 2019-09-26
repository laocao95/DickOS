defmodule Topology do
    def full(numNodes, topology) do
        neighborList = for i <- 1..numNodes do
            subList = 
            for j <- 1..numNodes  do
                if (j !== i) do
                    j
                end
            end
            subList=Enum.reject(subList, &is_nil/1)
        end
    end

    def getNeighbor(numNodes, topology) do
        full(numNodes, topology)
    end
end


IO.inspect(Topology.full(10, "test"))