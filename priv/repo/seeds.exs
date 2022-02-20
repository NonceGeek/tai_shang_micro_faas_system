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
    "x6udI0Gy56KI3jg7EP_yhOLt7EwHtYHlZJpLH8yFSMw",
    "rr5p8_FJ4l0KvjhCtIzmxfBNN3UiN2Cv2Ml08ys9odE"
  ]

Enum.map(tx_ids, fn tx_id ->
  OnChainCode.create_by_tx_id(tx_id)
end)
