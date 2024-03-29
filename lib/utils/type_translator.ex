defmodule TypeTranslator do
    @doc """
      TODO: impl the cases.
      iex(34)> ABI.encode("buy(uint256,uint256)", [13721, 10000000000000000])
      iex(33)> ABI.decode("buy(uint256,uint256)", "d6febde80000000000000000000000000000000000000000000000000000000000003599000000000000000000000000000000000000000000000000002386f26fc10000" |> Base.decode16!(case: :lower))
[97245039436039886927109785377494219820477888259653562449568703439859083116544,
 369917428219973928622626114008996352472975258621679195013222636231821042]
    """

    def str_to_module(class, mod_name) do
      "Elixir.TaiShangWorldGenerator.#{class}.#{mod_name}"
      |> String.to_atom()
    end

    def bin_to_list(bin) do
      :binary.bin_to_list(bin)
    end

    def data_to_int(raw) do
      raw
      |> hex_to_bin()
      |> ABI.TypeDecoder.decode_raw([{:uint, 256}])
      |> List.first()
    end

    def data_to_str(raw) do
      raw
      |> hex_to_bin()
      |> ABI.TypeDecoder.decode_raw([:string])
      |> List.first()
    end

    def data_to_addr(raw) do
      addr_bin =
        raw
        |> hex_to_bin()
        |> ABI.TypeDecoder.decode_raw([:address])
        |> List.first()

      "0x" <> Base.encode16(addr_bin, case: :lower)
    end

    def hex_to_bin(hex) do
      hex
      |> String.slice(2..-1)
      |> Base.decode16!(case: :lower)
    end

    def hex_to_int(hex) do
      hex
      |> String.slice(2..-1)
      |> String.to_integer(16)
    end
    def hex_to_bytes(hex) do
      hex
      |> String.slice(2..-1)
      |> Base.decode16(case: :mixed)
    end

    def int_to_hex(int) do
      payload =
        int
        |> Integer.to_string(16)
        |> String.downcase()
      "0x" <> payload
    end

    @spec addr_to_bin(String.t()) :: Binary.t()
    def addr_to_bin(addr_str) do
      addr_str
      |> String.replace("0x", "")
      |> Base.decode16!(case: :mixed)
    end

    def get_data(func_str, params) do
      payload =
        func_str
        |> ABI.encode(params)
        |> Base.encode16(case: :lower)

      "0x" <> payload
    end
  end
