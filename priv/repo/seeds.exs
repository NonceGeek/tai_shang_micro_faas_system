# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TaiShangMicroFaasSystem.Repo.insert!(%TaiShangMicroFaasSystem.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TaiShangMicroFaasSystem.OnChainCode

tx_ids_on_arweave =
  [
    # "-6TxJsLSeoXfEhKfGzG5-n65QpAbuiwp4fO_7-2A-vA", # BestBlockHeightGetter
    # "ghBIjdbs2HpGM0Huy3IV0Ynm9OOWxDLkcW6q0X7atqs", # EndpointProvider
    # "kqozWQAcbDr3S_hSEi91O4eQ28tpDvrOKj0xlQ6_dKw", # BlockToAsciiEmojiTranslator
    # "rr5p8_FJ4l0KvjhCtIzmxfBNN3UiN2Cv2Ml08ys9odE", # AsciiDrawer
    # "UzvTGCxCg0xB2mDqX27vPf_nTz4TjUaGRYZeJ3GsuM0", # Verifier
    "1R7Y8U1bjC0EGePqHDC_0ODY-GiWxOw_rUPQOfXZLGA", # NftRender.NType
  ]

Enum.map(tx_ids_on_arweave, fn tx_id ->
  OnChainCode.create_or_query_by_tx_id(tx_id)
end)

tx_id_on_ipfs =
  []
tx_ids_on_gist =
  ["0f1350bdfa4a119e2cbf8cf52d2a109c"]
  # ["8634a21477ea60785783cc0642ba4133"] # Contract Syncer
Enum.map(tx_ids_on_gist, fn tx_id ->
  OnChainCode.create_or_query_by_tx_id(tx_id, "gist")
end)

secret_seeds = "priv/repo/secret.seeds.exs"
if File.exists?(secret_seeds) do
  Code.eval_file(secret_seeds)
end
