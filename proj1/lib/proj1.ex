defmodule Worker do
  def start(boss) do
    receive do
      {:task, start_num, end_num} -> 
        {process_time, value} = :timer.tc(fn -> VamNum.vampireNum(boss, start_num, end_num) end)
        send boss, {:complete, process_time}
    end
  end
end

defmodule Boss do
  def start(start_num, end_num, worker_num, chunk) do

    for n <- 0..worker_num-1, do:
    (
      worker = spawn(Worker, :start, [self()]) 
      # IO.inspect(worker)
      if n == worker_num-1 do
          send worker, {:task, start_num + n * chunk, end_num}
      else
          send worker, {:task, start_num + n * chunk, start_num + (n + 1) * chunk - 1}
      end
    )
    receiveMsg(0, worker_num, %{}, 0)
  end

  def receiveMsg(worker_completed_count, worker_num, ans_map, cpu_time) do
    receive do
      {:found, vam_num, li} ->
          new_map = Map.put(ans_map, Integer.to_string(vam_num), li)
          receiveMsg(worker_completed_count, worker_num, new_map, cpu_time)
      {:complete, process_time} -> 
        completeSub(worker_completed_count + 1, worker_num, ans_map, cpu_time + process_time)

      # {:found, vam_num, {fangs1, fangs2}} ->
      #   # IO.puts(Integer.to_string(vam_num) <> " " <> Integer.to_string(fangs1) <> " " <> Integer.to_string(fangs2))
      #   return_pattern = Map.fetch(ans_map, Integer.to_string(vam_num))
      #   case return_pattern do
      #     {:ok, value} ->
      #       # IO.puts("already one")
      #       new_value = value ++ [Integer.to_string(fangs1), Integer.to_string(fangs2)]
      #       new_map = Map.put(ans_map, Integer.to_string(vam_num), new_value)
      #       receiveMsg(worker_completed_count, worker_num, new_map, cpu_time)
      #     :error -> 
      #       new_map = Map.put(ans_map, Integer.to_string(vam_num), [Integer.to_string(fangs1), Integer.to_string(fangs2)])
      #       receiveMsg(worker_completed_count, worker_num, new_map, cpu_time)
      #   end
    end
    
  end

  def completeSub(worker_completed_count, worker_num, ans_map, cpu_time) do
    if worker_completed_count == worker_num do
      # IO.puts("Complete")
      {cpu_time, ans_map}
    else
      # IO.puts("subComplete")
      receiveMsg(worker_completed_count, worker_num, ans_map, cpu_time)
    end
  end
end