defmodule Proj2.CLI do
  def main(args \\ []) do
      args
      |> parse_args
  end

  defp parse_args(args) do
      {opts, args, _} =
        args
        |> OptionParser.parse(strict: [:string])
      
      numNodes = Enum.at(args, 0) |> String.to_integer()
      topology = Enum.at(args, 1)
      algorithm = Enum.at(args, 2)

      start(numNodes, topology, algorithm)
  end

  def start(numNodes, topology, algorithm) do
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
      
      checkAlive(serverpid)
  end
  
  def checkAlive(pid) do
      if Process.alive?(pid) == true do
          checkAlive(pid)
      end
  end
end