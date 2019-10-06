defmodule ElixirPbt.Buggy do
  def split(str, delimeter) when is_binary(str) and is_binary(delimeter) do
    case String.ends_with?(str, delimeter) do
      true ->
        IO.puts("ends with delimeter: d=\"#{delimeter}\" str=\"#{str}\"")

        str
        |> String.split(delimeter)
        |> Enum.reverse()
        |> tl()
        |> Enum.reverse()

      false ->
        String.split(str, delimeter)
    end
  end
end
