defmodule VamNum do
    def vampireNum({low, high}) do
        for m <- 100..999, do:
        (
            for n <- m..999, do:
            (
                target = m * n
                if rem(target - m - n, 9) == 0 && target >= low && target <= high && rem(target, 100) != 0 do
                    start_digit = [div(m, 100), rem(div(m, 10), 10), rem(m, 10), div(n, 100), rem(div(n, 10), 10), rem(n, 10)]
                    product_digit = [div(target, 100000), rem(div(target, 10000), 10), rem(div(target, 1000), 10), rem(div(target, 100), 10), rem(div(target, 10), 10), rem(target, 10)]

                    start = Enum.sort(start_digit)
                    product = Enum.sort(product_digit)
                    # start = Enum.at(start_digit, 0) * 100000 + Enum.at(start_digit, 1) * 10000 + Enum.at(start_digit, 2) * 1000 + Enum.at(start_digit, 3) * 100 + Enum.at(start_digit, 4) * 10 + Enum.at(start_digit, 5)
                    # IO.puts(start)
                    # IO.puts(target)
                    # product = Enum.at(product_digit, 0) * 100000 + Enum.at(product_digit, 1) * 10000 + Enum.at(product_digit, 2) * 1000 + Enum.at(product_digit, 3) * 100 + Enum.at(product_digit, 4) * 10 + Enum.at(product_digit, 5)
                    # IO.puts(product)
                    # IO.puts("  ")
                    if Enum.at(product, 0) == Enum.at(start, 0) && Enum.at(product, 1) == Enum.at(start, 1) && Enum.at(product, 2) == Enum.at(start, 2) && Enum.at(product, 3) == Enum.at(start, 3) && Enum.at(product, 4) == Enum.at(start, 4) && Enum.at(product, 5) == Enum.at(start, 5)do
                        IO.puts(m)
                        IO.puts(n)
                        IO.puts(target)
                    end

                    # touchSix(product_digit, start_digit, target, m, n, 0, 0, 6)
                    
                    
                    # count = 0
                    # for i <- 0..5, do:
                    # (
                    #     for j <- 0..5, do:
                    #     (
                    #         if Enum.at(product_digit, i) == Enum.at(start_digit, j) do
                    #             count = count + 1
                    #             IO.puts(count)
                    #             if count == 6 do
                    #                 IO.puts(target)
                    #             end
                    #         end
                    #     )
                    # )


                    # Enum.sort(start_digit)
                    # Enum.sort(product_digit)
                    # IO.puts(target)
                    # if Enum.at(start_digit, 0) == Enum.at(product_digit, 0) && Enum.at(start_digit, 1) == Enum.at(product_digit, 1) && Enum.at(start_digit, 2) == Enum.at(product_digit, 2) && Enum.at(start_digit,3) == Enum.at(product_digit, 3) && Enum.at(start_digit, 4) == Enum.at(product_digit, 4) && Enum.at(start_digit, 5) == Enum.at(product_digit, 5) do
                    #     IO.puts(m)
                    #     IO.puts(n)
                    #     IO.puts(target)
                    # end
                end
            )
        )
    end
end
