defmodule Worker do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def handle_cast({:task, start_num, end_num}, state) do
    {boss} = state
    {process_time, _} = :timer.tc(fn -> VamNum.vampireNum(boss, start_num, end_num) end)
    GenServer.cast(boss, {:complete, process_time})
    {:stop, :normal, state}
  end

end


defmodule Boss do
  use GenServer
  #record main process id
  def init(args) do
    # {mainid, worker_num, worker_completed_count, cpu_time, ans_map} = args
    {:ok, args}
  end


  def handle_cast({:start, start_num, end_num, chunk}, state) do

    {mainid, worker_num, worker_completed_count, cpu_time, ans_map} = state

    for n <- 0..worker_num-1, do:
    (
      {:ok, workerid} = GenServer.start_link(Worker, {self()})
      # IO.inspect(worker)
      if n == worker_num-1 do
        GenServer.cast(workerid, {:task, start_num + n * chunk, end_num})
      else
        GenServer.cast(workerid, {:task, start_num + n * chunk, start_num + (n + 1) * chunk - 1})
      end
    )
    {:noreply, state}
  end

  def handle_call({:found, vam_num, li}, _from, state) do
    # IO.puts(vam_num)
    {mainid, worker_num, worker_completed_count, cpu_time, ans_map} = state
    new_map = Map.put(ans_map, Integer.to_string(vam_num), li)
    new_state = {mainid, worker_num, worker_completed_count, cpu_time, new_map}
    {:reply, new_state, new_state}
  end

  def handle_cast({:complete, process_time}, state) do

    {mainid, worker_num, worker_completed_count, cpu_time, ans_map} = state
    
    new_cpu_time = cpu_time + process_time
    new_worker_completed_count = worker_completed_count + 1
    new_state = {mainid, worker_num, new_worker_completed_count, new_cpu_time, ans_map}
    
    if new_worker_completed_count == worker_num do
      # GenServer.reply(mainid, {new_cpu_time, ans_map})
      send mainid, {:down, new_cpu_time, ans_map}
      {:stop, :normal, new_state}
    else
      {:noreply, new_state}
    end    
  end

  # def receiveMsg(genpid, worker_completed_count, worker_num, cpu_time) do
  #   receive do
  #     {:complete, process_time} -> 
  #       completeSub(genpid, worker_completed_count + 1, worker_num, cpu_time + process_time)
  #     {:found, vam_num, {fangs1, fangs2}} ->
  #       # IO.puts(Integer.to_string(vam_num) <> " " <> Integer.to_string(fangs1) <> " " <> Integer.to_string(fangs2))
  #       return_pattern = Map.fetch(ans_map, Integer.to_string(vam_num))
  #       case return_pattern do
  #         {:ok, value} ->
  #           # IO.puts("already one")
  #           new_value = value ++ [Integer.to_string(fangs1), Integer.to_string(fangs2)]
  #           new_map = Map.put(ans_map, Integer.to_string(vam_num), new_value)
  #           receiveMsg(worker_completed_count, worker_num, new_map, cpu_time)
  #         :error -> 
  #           new_map = Map.put(ans_map, Integer.to_string(vam_num), [Integer.to_string(fangs1), Integer.to_string(fangs2)])
  #           receiveMsg(worker_completed_count, worker_num, new_map, cpu_time)
  #       end
  #   end
    
  # end

  # def completeSub(genpid, worker_completed_count, worker_num, cpu_time) do
  #   if worker_completed_count == worker_num do
  #     ans_map = GenServer.call(genpid, :get)
  #     {cpu_time, ans_map}
  #   else
  #     receiveMsg(genpid, worker_completed_count, worker_num, cpu_time)
  #   end
  # end
end