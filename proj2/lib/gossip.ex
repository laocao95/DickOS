defmodule GossipServer do
    num = 10
    algorithm = "gossip"
    topology = "network"


    neighbourList = Topology.getNeighbour(algorithm, topology)
    

end



defmodule GossipActor do
    use GenServer

    def init(initialState) do
        {:ok,initialState}
    end

    def handlecast do {

    }

end