defmodule Worker do
  def start(boss, genpid) do
    receive do
      {:task, start_num, end_num} -> 
        {process_time, _} = :timer.tc(fn -> VamNum.vampireNum(genpid, start_num, end_num) end)
        send boss, {:complete, process_time}
    end
  end
end

defmodule FangsReceiver do
  use GenServer

  def init(ans_map) do
    {:ok, ans_map}
  end

  def handle_call({:found, vam_num, li}, _from, ans_map) do
    # IO.puts(vam_num)
    new_map = Map.put(ans_map, Integer.to_string(vam_num), li)
    {:reply, new_map, new_map}
  end

  def handle_call(:get, _from, ans_map) do
    {:stop, :normal, ans_map, ans_map}
    # {:reply, ans_map, ans_map}
  end

end


defmodule Boss do

  def start(genpid, start_num, end_num, worker_num, chunk) do

    for n <- 0..worker_num-1, do:
    (
      worker = spawn(Worker, :start, [self(), genpid]) 
      # IO.inspect(worker)
      if n == worker_num-1 do
          send worker, {:task, start_num + n * chunk, end_num}
      else
          send worker, {:task, start_num + n * chunk, start_num + (n + 1) * chunk - 1}
      end
    )
    receiveMsg(genpid, 0, worker_num, 0)
  end

  def receiveMsg(genpid, worker_completed_count, worker_num, cpu_time) do
    receive do
      {:complete, process_time} -> 
        completeSub(genpid, worker_completed_count + 1, worker_num, cpu_time + process_time)
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

  def completeSub(genpid, worker_completed_count, worker_num, cpu_time) do
    if worker_completed_count == worker_num do
      ans_map = GenServer.call(genpid, :get)
      {cpu_time, ans_map}
    else
      receiveMsg(genpid, worker_completed_count, worker_num, cpu_time)
    end
  end
end