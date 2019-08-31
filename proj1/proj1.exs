# IO.inspect System.argv
core_count = System.schedulers_online

# IO.puts(core_count)

startNum = String.to_integer(Enum.at(System.argv, 0))
endNum = String.to_integer(Enum.at(System.argv, 1))

chunk = div(endNum - startNum, core_count)
# IO.puts(IEx.Helpers.i(startNum))
# IO.puts(IEx.Helpers.i(endNum))
for n <- 0..core_count-1, do:
(
    if n == core_count-1 do
        VamNum.vampire_num({startNum + n * chunk, endNum})
    else
        VamNum.vampire_num({startNum + n * chunk, startNum + (n + 1) * chunk})
    end
)