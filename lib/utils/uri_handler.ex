defmodule URIHandler do

  @svg_header "data:image/svg+xml;base64,"
  def decode_uri(uri) do
    {
      :ok,
      %{parsed_path: %{data: raw_data, mediatype: mediatype}}
    } =
      URL.new(uri)
    do_decode_uri(raw_data, mediatype)
  end

  def do_decode_uri(data, "image/svg+xml"), do: data
  def do_decode_uri(data, "application/json") do
    data
    |> Poison.decode!()
    |> ExStructTranslator.to_atom_struct()
  end

  def encode_uri(uri) do
    @svg_header <> Base.encode64(uri)
  end
end
