defmodule Component.ArGraphQLInteractor do
  @url "https://arweave.net/graphql"

  def query_by_addr(eth_addr, url \\ @url) do
    body = build_body(eth_addr)
    request = %HTTPoison.Request{
      method: :post,
      url: url,
      headers: [
        {~s|Accept-Encoding|, ~s|gzip, deflate, br|},
        {~s|Content-Type|, ~s|application/json|},
        {~s|Accept|, ~s|application/json|},
        {~s|Connection|, ~s|keep-alive|},
        {~s|DNT|, ~s|1|},
        {~s|Origin|, ~s|https://arweave.net|},
      ],
      body: body
    }
    try do
      {:ok, %{body: body, status_code: 200}} = HTTPoison.request(request)
      {:ok, body |> Poison.decode!() |> ExStructTranslator.to_atom_struct()}
    rescue
      error ->
      {:error, inspect(error)}
    end
  end

  def build_body(eth_addr) do
    Poison.encode!(%{query:
      "query {transactions(tags: [{name: \"App-Name\", values: [\"MirrorXYZ\"]},
      {name: \"Contributor\", values: [\"#{eth_addr}\"]}]) {edges {node {id}}}}"})
  end
end
