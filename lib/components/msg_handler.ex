
  defmodule Components.MsgHandler do
    @valid_time 36000 # 10 hour #todo: it's more make sense to make it as param
    # +---------------------+
    # | msg with timestamps |
    # +---------------------+

    def rand_msg(), do: "0x#{RandGen.gen_hex(16)}_#{timestamp_now()}"
    def rand_msg(:str), do: "0x#{RandGen.gen_hex(16)}"

    def time_valid?(msg) do
      [_, timestamp] = String.split(msg, "_")
      timestamp
      |> String.to_integer()
      |> do_time_valid?(timestamp_now())
    end
    def timestamp_now(), do: :os.system_time(:second)

    defp do_time_valid?(time_before, time_now) when time_now - time_before < @valid_time do
      true
    end
    defp do_time_valid?(_time_before, _time_now), do: false
  end
