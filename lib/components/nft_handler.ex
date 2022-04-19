defmodule Components.NFTHandler do
  def parse_token_uri(payload_raw) do
    %{image: img_raw} =
      payload =
        URIHandler.decode_uri(payload_raw)
    img_parsed =
      URIHandler.decode_uri(img_raw)
    %{payload: payload, img_parsed: img_parsed}
  end

  def encode_uri(uri, :svg), do: URIHandler.encode_uri(uri)
end
