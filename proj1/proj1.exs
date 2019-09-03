# IO.inspect System.argv
core_count = System.schedulers_online


start_num = String.to_integer(Enum.at(System.argv, 0))
end_num = String.to_integer(Enum.at(System.argv, 1))

chunk = div(end_num - start_num, core_count)

{real_time, {cpu_time, result}} = :timer.tc(fn -> Boss.start(start_num, end_num, core_count, chunk) end)

for {k, v} <- result do
    IO.write(k)
    for pair <- v do 
        IO.write(" " <> (elem(pair, 0) |> Integer.to_string()) <> " " <> (elem(pair, 1) |> Integer.to_string()))
    end
    IO.write("\n")
end

IO.puts("cpu time " <> Integer.to_string(cpu_time))
IO.puts("real time " <> Integer.to_string(real_time))
IO.puts("ratio " <> ( (cpu_time / real_time) |> Float.floor(3) |> Float.to_string()))