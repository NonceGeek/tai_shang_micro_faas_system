# FunctionServerBasedOnArweave

<img width="300" alt="image" src="https://user-images.githubusercontent.com/12784118/156332875-41467bba-7ffe-4e86-9248-0440075e338c.png">

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).


## Troubleshooting

1. `ERROR 42501 (insufficient_privilege) permission denied to create database`

    Please alter your postgres sql role in terminal, here is a example:

    ```sh
    $ psql
    psql (14.2)
    Type "help" for help.
    
    lucas=# ALTER USER postgres WITH CREATEDB;
    ALTER ROLE
    lucas=# \q
    ```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# WhitePaper

## 0x01 Introduction

Based on Arweave's FaaS system, code snippets written in languages such as Elixir/Rust can be pulled from the Arweave Network and loaded into Runtime to provide functional service support for other applications. Plugin is used for uploading code snippets.

![img](https://tva1.sinaimg.cn/large/e6c9d24egy1h0c0neoti6j21cc0jsdi5.jpg)

## 0x02 Background

###  2.1 What is FaaS

Function-as-a-Service is a supplementary service of traditional cloud services and many cloud service providers provide such services. For many Apps/dApps, they may only require simple back-end functions to get deployed at certain times in which case renting a server is not cost-efficient. In this case, they could choose to rent the function service and get charged per call of the function service.

From the perspective of the service purchaser, the use of FaaS saves the rental cost of the service; from the perspective of the service provider, a large number of function services on one server or cluster reduces the operating and maintenance cost.

### 2.2 Problems of the traditional FaaS

- **The closed form of the function makes it difficult to use across users**

Traditional FaaS can only be used by the demander who upload the functions for their own purpose. The code of the function cannot be guaranteed to be tamper-proof and transparent, and there is no way to record the executing process of the function. Therefore, without the assistance of blockchain technology, it is impossible to have an open function market where users can purchase and use functions based on their needs, or to carry out combining functions across users.  In conclusion, the opaque and closed nature of the function limits the potential of FaaS.

- **Stateless functions**

In addition, the functions provided by the traditional FaaS is stateless.

### 2.3 FaaS Based on Blockchain

Combining with blockchain, we can construct a new type of FaaS system

- **transparent, open, and immutable on-chain functions**

All code snippets, functions, and modules are stored in the Arweave blockchain, and dynamically loaded into memory while the FaaS service is running. The functions are transparent, open, and immutable. Therefore, it is possible to share the uploaded functions among users through an open function market, thus making F (in FaaS) a Lego building block.

- **allow state storage**

Through the functions, users can store the state on each blockchain network, and read the state from it. The authentication is realized through the signature that follows the Ethereum standard, which breaks through the `stateless` limitation of the traditional FaaS system.

## 0x03 How to Use

> https://faas.noncegeek.com/

### 3.1 Run Code by Interface

![img](https://tva1.sinaimg.cn/large/e6c9d24egy1h0c0nnbgyyg20ts0k9nmg.gif)

### 3.2 Run code by API

See in:

> https://github.com/WeLightProject/function_server_based_on_arweave/wiki/API-Docs

### 3.3 Upload, Use, and Share the code

FaaS admins can use all valid code snippet stored on AR network via `Tx ID` (Code Market will be launched in the future)! Through the `Add new Function by Tx id` page, admins can dynamically pull the code from the Arweave network. Uploading the code is achieved through `dApp/Plugin` which is decoupled from FaaS.

#### 3.3.1 Two methods to upload the code

![img](https://r8jmm3f9xe.feishu.cn/space/api/box/stream/download/asynccode/?code=ZGM4Y2U1MjE4NTM0NDZkZWIyY2NkMzE4NmM2ODNkNWFfa3I3dDlXNHpGRmNIeUtKOTc3YzBXT2tIMEQxNFhCMk1fVG9rZW46Ym94Y25ER1IzWHhSaVBNNHVYM2NMWHppY1BnXzE2NDc0MzUyMDg6MTY0NzQzODgwOF9WNA)

- **Method A**

Upload the code through dApp based on AR Network and pay for the storage via AR Token. 

![img](https://tva1.sinaimg.cn/large/e6c9d24egy1h0c0nrk6ghj21js0u0tc9.jpg)

- **Method B**

Upload the code via a Bundlr-based plugin and pay for the storage via Matic Token on Polygon.

![img](https://tva1.sinaimg.cn/large/e6c9d24egy1h0c0nybmynj211409xmy9.jpg)

#### 3.3.2 Load the code snippet from the AR network

![img](https://tva1.sinaimg.cn/large/e6c9d24egy1h0c0okj68ej21fg0jwjsu.jpg)

Enter the `Tx ID` and admin token to load the code snippet from the AR network into the FaaS service.

### 3.4 Run Your Own FaaS system

TaiShang FaaS is a distributed Open Source FaaS platform. Individuals and developers can build their own FaaS service and customize their own on-chain functions and modules for different types of usage.

See guide in the part 1 in the `README.md`:

> https://github.com/WeLightProject/function_server_based_on_arweave

## 0x04 Snippet Examples

### 4.1 Template Snippet

```elixir
defmodule CodesOnChain.#{Mod_Name} do    
  @moduledoc """
    the description of this module.
  """

  def get_module_doc, do: @moduledoc # 固定函数，用以获取模块文档  
  
  @spec func_name(type) :: type # spec 不是必须的，但是最好有，表明输入变量与输出变量的类型
  def func_name(var) do
      # 此处是具体的函数实现
      # 最后一个变量是返回结果
      result
  end
end
```

### 4.2 Snippet embodies functional pattern matching

Depending on the accepted parameter, it will be adapted to different `get ascii()` functions, which is undoubtedly clearer than the traditional `if` statement or `switch` method.

```elixir
defmodule CodesOnChain.AsciiDrawer do    
  @moduledoc """
    This is an code-on-chain example:
      Draw ascii pic with param
  """

  def get_module_doc, do: @moduledoc
  @spec get_ascii(String.t()) :: String.t()
  def get_ascii("surprised"), do: "( ✧Д✧) OMG!!"
  def get_ascii("confuse"), do: "(๑•﹏•)⋆* ⁑⋆*"
  def get_ascii("happy"), do: "        (´ ∀ ` *)"
  def get_ascii("table_fliper"), do: "（╯ ͡° ل͜ ͡°）╯︵ ┻━┻"

end
```

![img](https://r8jmm3f9xe.feishu.cn/space/api/box/stream/download/asynccode/?code=NWNiOTczNWExY2VhNDQ3ZTA4ZTE1ZTUwYTI1YTBkZWJfODNuMUtGVzhpcDFiUHgyTjF5M1pNZWFKOW9wenNOWXNfVG9rZW46Ym94Y243d3BBMXQwMFE5U3NKa21HT1dKM1NnXzE2NDc0MzUyMDg6MTY0NzQzODgwOF9WNA)



### 4.3 Data-Storage Snippet

Store the data in the form of Key-Value.

```Julia
defmodule CodesOnChain.EndpointProvider do
  @moduledoc """
    Provide Endopoints of multi-chain by func
  """

  @endpoints %{
    "ethereum" => "https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
    "polygon" => "https://polygon-rpc.com",
    "moonbeam" => "https://rpc.api.moonbeam.network",
    "arweave" => "https://arweave.net"
  }

  def get_module_doc, do: @moduledoc

  @spec get_endpoints() :: map()
  def get_endpoints(), do: @endpoints

end
```

![58159785-4fff-4714-a68e-347a963da461](https://tva1.sinaimg.cn/large/e6c9d24egy1h0c0ql8owbj20zk0tc0wb.jpg)

### 4.4 Get On-Chain Data Snippet

The example code below is using the `pipe operator` in Elixir.

```Erlang
height |> String.slice(2..-1) |> String.to_integer(16)
```

That allows us to avoid using nesting methods like this.

```Erlang
func_a(func_b(func_c(x,y,z)))
```

That also makes the code snippet more readable.

```elixir
defmodule CodesOnChain.BestBlockHeightGetter do
  @moduledoc """
    This is an code-on-chain example:
      Shows how to get the current block height on dif chain.
  """

  def get_module_doc, do: @moduledoc

  @spec get_best_block_height(String.t(), String.t()) :: integer()
  def get_best_block_height("ethereum", endpoint) do
    {:ok, height} = Ethereumex.HttpClient.eth_block_number(url: endpoint)
    height |> String.slice(2..-1) |> String.to_integer(16)
  end

  def get_best_block_height("arweave", endpoint) do
    ArweaveSdkEx.block_height(endpoint)
  end

end
```

### 4.5 The Combined Snippet

This code snippet combined those three code snippets above and embodies the function composability under the new FaaS idea.

The `defp` is a private function.

```elixir
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
  alias FunctionServerBasedOnArweave.CodeRunnerSpec
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
```

### 4.6 The Verifier Snippet

It's a complicated example with test functions.

It showed how to verify the ethereum message signature by on-chain snippet!

```elixir
defmodule CodesOnChain.Verifier do
  @moduledoc """
    An Example to verify the ethereum msg signature.
  """

  @ethereum_message_prefix "\x19Ethereum Signed Message:\n"
  @base_recovery_id 27
  @base_recovery_id_eip_155 35

  def get_module_doc, do: @moduledoc

  @doc "Verifies if a message was signed by a wallet keypair given a the public address, message, signature"
  @spec verify_message?(String.t(), String.t(), String.t()) :: boolean
  def verify_message?(public_address, message, signature) do
    hash = hash_message(message)

    case verify_signature(hash, signature) do
      {:ok, recovered_key} ->
        recovered_address = get_address(recovered_key)
        String.downcase(recovered_address) == String.downcase(public_address)

      _ ->
        false
    end
  end

  @doc "Get Public Ethereum Address from Public Key"
  @spec get_address(String.t()) :: String.t()
  def get_address(public_key) do
    <<4::size(8), key::binary-size(64)>> = public_key
    <<_::binary-size(12), eth_address::binary-size(20)>> = ExKeccak.hash_256(key)
    "0x#{Base.encode16(eth_address)}"
  end

  # ------ simple test ------
  def test_valid_verify_message() do
    verify_message?(
      "0x132b9dbb51f336d6f43e4b8078b5c5ae737e2ef9",
      "test",
      "0x57d23d24c09c627f17b9696df8ce442ee719aa0a8e7d888dea25b39cd740c4b661cc2c2901af114f44e1c43d09660db728d1ee334878217a96894bca5eada4b21b"
    )
  end

  def test_invalid_verify_message() do
    verify_message?(
      "0x132b9dbb51f336d6f43e4b8078b5c5ae737e2ef9",
      "test",
      "0x66d23d24c09c627f17b9696df8ce442ee719aa0a8e7d888dea25b39cd740c4b661cc2c2901af114f44e1c43d09660db728d1ee334878217a96894bca5eada4b21b"
    )
  end

  # ------ defps ------

  @doc "Hashes a binary message and removes ethereum message prefix & length from the beginning of the binary."
  defp hash_message(message) when is_binary(message) do
    eth_message = @ethereum_message_prefix <> get_message_length_bytes(message) <> message
    ExKeccak.hash_256(eth_message)
  end

  defp get_message_length_bytes(message) when is_binary(message) do
    Integer.to_string(String.length(message))
  end

  @doc "Destructure a signature to r, s, v to be used by Secp256k1 recover"
  defp destructure_sig(sig) do
    r = sig |> String.slice(2, 64) |> Base.decode16!(case: :lower)
    s = sig |> String.slice(66, 64) |> Base.decode16!(case: :lower)

    {v, _} =
      sig
      |> String.slice(130, 2)
      |> String.upcase()
      |> Integer.parse(16)

    {:ok, v, _} = decode_signature(v)

    {r, s, v}
  end

  defp decode_signature(signature_v) do
    # There are three cases:
    #  1. It is a simple 0,1 recovery id
    #  2. It is 0,1 + base recovery_id, in which case we need to subtract that and add EIP-155
    #  3. It is already EIP-155 compliant

    cond do
      is_simple_signature?(signature_v) ->
        {:ok, signature_v, nil}

      is_pre_eip_155_signature?(signature_v) ->
        {:ok, signature_v - @base_recovery_id, nil}

      true ->
        network_id = trunc((signature_v - @base_recovery_id_eip_155) / 2)

        {:ok, signature_v - @base_recovery_id_eip_155 - network_id * 2, network_id}
    end
  end

  @doc "Returns true is signature is simple 0,1-type recovery_id"
  defp is_simple_signature?(v), do: v < @base_recovery_id

  @doc "Returns true if signature is pre EIP-155 Ethereum signature"
  defp is_pre_eip_155_signature?(v), do: v < @base_recovery_id_eip_155

  defp verify_signature(hash, signature) do
    {r, s, v} = destructure_sig(signature)
    :libsecp256k1.ecdsa_recover_compact(hash, r <> s, :uncompressed, v)
  end
end
```

## 0x05 Team & Contributors Introduction

NonceGeek -- Cool-Oriented Programming.

> https://noncegeek.com/
