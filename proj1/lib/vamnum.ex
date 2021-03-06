defmodule VamNum do
    def findFactors(n) do
        half = div(length(to_charlist(n)), 2)
        sorted = Enum.sort(String.codepoints("#{n}"))
        Enum.filter(pairs(n), fn {a, b} -> length(to_charlist(a)) == half && length(to_charlist(b)) == half && Enum.count([a, b], fn x -> rem(x, 10) == 0 end) != 2
            && Enum.sort(String.codepoints("#{a}#{b}")) == sorted end)
    end

    def pairs(n) do
        start_factor = trunc(n / :math.pow(10, div(length(to_charlist(n)), 2)))
        end_factor  = :math.sqrt(n) |> round
        for i <- start_factor .. end_factor, rem(n, i) == 0, do:
            {i, div(n, i)}
    end

    def vampireNum(boss, low, high) do
        low..high |>
        Enum.filter(fn n -> rem(length(to_charlist(n)), 2) == 0 end) |>
        Enum.each(fn n -> 
            ans = findFactors(n)
            if length(ans) > 0 do 
                #send boss, {:found, n, ans}
                GenServer.call(boss, {:found, n, ans}, 50)
            end
        end)
        # Enum.reduce_while(low..high, low, fn n, acc ->
        #     case vampire_factors(n) do
        #         [] -> {:cont, acc}
        #         vf -> IO.puts "#{n}:\t#{inspect vf}"
        #     #   vf -> send boss, {:found, n, inspect vf}
        #         if n < high, do: {:cont, acc+1}, else: {:halt, acc}
        #     end
        #   end)

        # for m <- 100..999, do:
        # (
        #     for n <- m..999, do:
        #     (
        #         target = m * n
        #         if rem(target - m - n, 9) == 0 && target >= low && target <= high && rem(target, 100) != 0 do
        #             start_digit = [div(m, 100), rem(div(m, 10), 10), rem(m, 10), div(n, 100), rem(div(n, 10), 10), rem(n, 10)]
        #             product_digit = [div(target, 100000), rem(div(target, 10000), 10), rem(div(target, 1000), 10), rem(div(target, 100), 10), rem(div(target, 10), 10), rem(target, 10)]

        #             start = Enum.sort(start_digit)
        #             product = Enum.sort(product_digit)
        #             if Enum.at(product, 0) == Enum.at(start, 0) && Enum.at(product, 1) == Enum.at(start, 1) && Enum.at(product, 2) == Enum.at(start, 2) && Enum.at(product, 3) == Enum.at(start, 3) && Enum.at(product, 4) == Enum.at(start, 4) && Enum.at(product, 5) == Enum.at(start, 5)do
        #                 send boss, {:found, target, m, n}
        #             end
        #         end
        #     )
        # )
    end

end
