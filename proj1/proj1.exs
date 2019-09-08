# IO.inspect System.argv
core_count = System.schedulers_online

start_num = String.to_integer(Enum.at(System.argv, 0))
end_num = String.to_integer(Enum.at(System.argv, 1))

chunk = div(end_num - start_num, core_count)

# args: {mainid, worker_num, worker_completed_count, cpu_time, ans_map}
start_time = System.monotonic_time(:microsecond)

{:ok, bossid} = GenServer.start_link(Boss, {self(), core_count, 0, 0, %{}})

# {real_time, {cpu_time, result}} = :timer.tc(fn -> Boss.start(genpid, start_num, end_num, core_count, chunk) end)

GenServer.cast(bossid, {:start, start_num, end_num, chunk})

receive do
    {:down, cpu_time, ans_map} ->
        #real_time = System.monotonic_time(:microsecond) - start_time
        for {k, v} <- ans_map do
            IO.write(k)
            for pair <- v do 
                IO.write(" " <> (elem(pair, 0) |> Integer.to_string()) <> " " <> (elem(pair, 1) |> Integer.to_string()))
            end
            IO.write("\n")
        end
        # IO.puts("cpu time " <> Integer.to_string(cpu_time))
        # IO.puts("real time " <> Integer.to_string(real_time))
        # IO.puts("ratio " <> ( (cpu_time / real_time) |> Float.floor(3) |> Float.to_string()))
end