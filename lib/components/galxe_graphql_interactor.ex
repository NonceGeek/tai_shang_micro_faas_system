defmodule Components.GalxeGraphQLInteractor do

    @url "https://graphigo.prd.galaxy.eco/query"
    alias Neuron.Config

    def query_campaign_list(the_alias, fir, aft) do
        Config.set(url: @url)
        body = "query CampaignList(\n  $id: Int\n  $alias: String\n  $campaignInput: ListCampaignInput!\n) {\n  space(id: $id, alias: $alias) {\n    id\n    name\n    alias\n    campaigns(input: $campaignInput) {\n      pageInfo {\n        endCursor\n        hasNextPage\n      }\n      list {\n        id\n        name\n      }\n    }\n  }\n}"
        data = %{
            alias: the_alias,
            campaignInput: %{
                after: "#{aft}",
                chains: nil,
                credSources: nil,
                excludeChildren: true,
                first: fir,
                forAdmin: false,
                gasTypes: nil,
                listType: "Newest",
                rewardTypes: nil,
                searchString: nil,
                statuses: nil,
                types: ["Drop", "MysteryBox", "Forge", "MysteryBoxWR", "Airdrop",
                "ExternalLink", "OptIn", "OptInEmail", "PowahDrop", "Parent", "Oat",
                "Bounty", "Token", "DiscordRole", "Mintlist", "Points", "PointsMysteryBox"]
            }
        }
        Neuron.query(body, data)
    end

    def query(query_body, url \\ @url) do
        request = %HTTPoison.Request{
        method: :post,
        url: url,
              headers: [
        {~s|Content-Type|, ~s|application/json|},
        {~s|Accept|, ~s|application/json|},
        {~s|Connection|, ~s|keep-alive|},
        {~s|DNT|, ~s|1|},
      ],
        body: query_body
        }
        try do
            {:ok, %{body: body, status_code: 200}} = HTTPoison.request(request)
            {:ok, body |> Poison.decode!() |> ExStructTranslator.to_atom_struct()}
        rescue
        error ->
            {:error, inspect(error)}
        end
    end

    def build_body_query_nft_holder(campaign_id, block, fir, aft) do
        Poison.encode!(%{query:
        "query NFTHolders {\n  campaign(id: \"#{campaign_id}\") {\n    nftHolderSnapshot {\n      holders(block: #{block}, first: #{fir}, after: \"#{aft}\") {\n        list {\n          id\n          holder\n        }\n        totalCount\n        edges {\n          node {\n            id\n            holder\n          }\n          cursor\n        }\n        pageInfo {\n          startCursor\n          endCursor\n          hasNextPage\n          hasPreviousPage\n        }\n      }\n    }\n  }\n}\n"
        })
    end

    # def build
end