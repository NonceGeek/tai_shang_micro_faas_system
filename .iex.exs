best_block_height_getter =
  File.read!("examples/best_block_height_getter.ex")
endpoint_provider =
  File.read!("examples/endpoint_provider.ex")

block_to_ascii_emoji_translator =
  File.read!("examples/block_to_game_map_translator.ex")
alias FunctionServerBasedOnArweave.DataToChain

conn = %Components.Ipfs.Connection{}

dao_info_exp = %{
    "description" => "it's just a cool DAO.",
    "logo" => "https://tva1.sinaimg.cn/large/e6c9d24egy1h2rb87iw5ij20je0j8t9t.jpg",
    "homepage" => "https://google.com",
    "name" => "coolDAO",
    "template_gist_id" => "xxxx",
    "verified_erc721_contract" => "xxxx"
  }
