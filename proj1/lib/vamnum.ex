defmodule VamNum do
    def vampireNum(boss, low, high) do
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
                    if Enum.at(product, 0) == Enum.at(start, 0) && Enum.at(product, 1) == Enum.at(start, 1) && Enum.at(product, 2) == Enum.at(start, 2) && Enum.at(product, 3) == Enum.at(start, 3) && Enum.at(product, 4) == Enum.at(start, 4) && Enum.at(product, 5) == Enum.at(start, 5)do
                        send boss, {:found, target, m, n}
                    end
                end
            )
        )
    end
end
