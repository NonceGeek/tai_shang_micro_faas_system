# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FunctionServerBasedOnArweave.Repo.insert!(%FunctionServerBasedOnArweave.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FunctionServerBasedOnArweave.OnChainCode

tx_ids =
  [
    "-6TxJsLSeoXfEhKfGzG5-n65QpAbuiwp4fO_7-2A-vA", # BestBlockHeightGetter
    "ghBIjdbs2HpGM0Huy3IV0Ynm9OOWxDLkcW6q0X7atqs", # EndpointProvider
    "kqozWQAcbDr3S_hSEi91O4eQ28tpDvrOKj0xlQ6_dKw", # BlockToAsciiEmojiTranslator
    "rr5p8_FJ4l0KvjhCtIzmxfBNN3UiN2Cv2Ml08ys9odE", # AsciiDrawer
    "UzvTGCxCg0xB2mDqX27vPf_nTz4TjUaGRYZeJ3GsuM0", # Verifier
    "ypcTmb19L6Xd7mw75tQ8oFDCAYyOoQT9Xb8uKU38jpw", # NftRender.NType
  ]

Enum.map(tx_ids, fn tx_id ->
  OnChainCode.create_or_query_by_tx_id(tx_id)
end)
