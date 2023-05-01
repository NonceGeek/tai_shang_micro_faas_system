defmodule CodesOnChain.BlockToAsciiEmojiTranslator do
  @moduledoc """
    This is an code-on-chain example:
      Translate block infomations to a map.
      This module used 2 other modules on chain.
  """
  @number_to_emoji %{
    0 => "surprised",
    1 => "confuse",
    2 => "happy",
    3 => "table_fliper",
  }

  # module in FaaS System.
  alias TaiShangMicroFaasSystem.CodeRunnerSpec
  def get_module_doc, do: @moduledoc


  @spec generate_emoji(String.t()) :: String.t()
  def generate_emoji(chain_name) do
    # step 0x01. get endpoint
    # check this module on:
    # https://viewblock.io/arweave/tx/ghBIjdbs2HpGM0Huy3IV0Ynm9OOWxDLkcW6q0X7atqs
    endpoint =
    "ghBIjdbs2HpGM0Huy3IV0Ynm9OOWxDLkcW6q0X7atqs"
    |> CodeRunnerSpec.run_ex_on_chain("get_endpoints", [])
    |> Map.get(chain_name)

    # step 0x02. get block height
    # check this module on:
    # https://viewblock.io/arweave/tx/-6TxJsLSeoXfEhKfGzG5-n65QpAbuiwp4fO_7-2A-vA
    block_height =
      CodeRunnerSpec.run_ex_on_chain(
        "-6TxJsLSeoXfEhKfGzG5-n65QpAbuiwp4fO_7-2A-vA",
        "get_best_block_height",
        [chain_name, endpoint]
      )


    # step 0x03. block to emoji
    block_height
    |> rem(4)
    |> number_to_emoji()
  end

  @spec number_to_emoji(integer()) :: String.t()
  defp number_to_emoji(number) do
    # check this module on:
    # https://viewblock.io/arweave/tx/-6TxJsLSeoXfEhKfGzG5-n65QpAbuiwp4fO_7-2A-vA
    CodeRunnerSpec.run_ex_on_chain(
      "rr5p8_FJ4l0KvjhCtIzmxfBNN3UiN2Cv2Ml08ys9odE",
      "get_ascii",
      [Map.get(@number_to_emoji, number)]
    )
  end

end
