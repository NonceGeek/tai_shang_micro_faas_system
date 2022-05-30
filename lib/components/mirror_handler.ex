defmodule Component.MirrorHandler do
  alias Component.ArGraphQLInteractor

  def get_articles(eth_addr, num \\ nil) do
    {:ok, %{data: %{transactions: %{edges: payloads }}}} =
      ArGraphQLInteractor.query_by_addr(eth_addr)
    payloads
    |> get_tx_ids()
    |> slice(num)
    |> do_get_articles(:digest)
  end

  def get_tx_ids(payloads) do
    Enum.map(payloads, fn %{node: %{id: tx_id}} ->
      tx_id
    end)
  end

  def slice(tx_ids, nil), do: tx_ids
  def slice(tx_ids, num) do
    Enum.slice(tx_ids, 0, num)
  end

  def do_get_articles(tx_ids, :digest) do
    tx_ids
    |> Enum.map(fn tx_id ->
      get_article(tx_id, :digest)
    end)
    |> combine_same_ori()
  end

  def get_article(tx_id, :digest) do
    {:ok, %{content: payload}} =
      Constants.get_arweave_node()
      |> ArweaveSdkEx.get_content_in_tx(tx_id)

    payload
    |> Poison.decode!()
    |>  ExStructTranslator.to_atom_struct()
    |> handle_content()
  end

  def handle_content(%{content: %{body: body} = payload, originalDigest: original_digest}) do
    { Map.put(payload, :body, String.slice(body, 0, 300)), original_digest}
  end

  def combine_same_ori(articles) do
    {articles_handled, _} =
      Enum.map_reduce(articles, "", fn {article, original_digest}, acc ->
        if original_digest == acc do
          # repeat yet.
          {nil, acc}
        else
          {article, original_digest}
        end
      end)

    Enum.reject(articles_handled, &(is_nil(&1)))
  end
end
