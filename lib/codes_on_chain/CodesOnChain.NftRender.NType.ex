defmodule CodesOnChain.NftRender.NType do
  @moduledoc """
    This module is use for render abstract NFT to an rendered NFT.
  """

  alias Components.NFTHandler

  @traits %{
    n: "<text",
    img: "<image"
    }

  @header %{
    origin: "<svg xmlns=\"http://www.w3.org/2000/svg\" preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 350 350\">",
    replace: "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 400 400\">"
  }

  @rect "<rect x=\"30\" width=\"380\" height=\"400\" style=\"fill:rgb(255,255,255);\" />"

  @resources %{
    first:  %{collection: [10, 11, 10, 11, 10, 11, 10, 11, 10, 11, 10, 11, 10, 11, 10, 11], x: 0, y: 0, height: 400, width: 400},
    second: %{collection: [20, 21, 20, 21, 20, 21, 20, 21, 20, 21, 20, 21, 20, 21, 20, 21], x: 0, y: 0, height: 400, width: 400},
    third: %{collection: [30, 31, 30, 31, 30, 31, 30, 31, 30, 31, 30, 31, 30, 31, 30, 31], x: 0, y: 0, height: 400 , width: 400},
  }

  @id_to_source %{
    10 => "background_400_400_1.png",
    11 => "background_400_400_2.png",
    # ---
    20 => "skincolor_400_400_1.png",
    21 => "skincolor_400_400_2.png",
    # ---
    30 => "face_400_400_1.png",
    31 => "face_400_400_2.png",
  }

  @keys [:first, :second, :third, :fourth, :fifth, :sixth]

  def get_module_doc, do: @moduledoc

  @spec handle_svg(String.t(), String.t()) :: map()
  def handle_svg(img_raw, base_url) do
    img_parsed =
      URIHandler.decode_uri(img_raw)
    img_handled = do_handle_svg(img_parsed, base_url)
    %{}
    |> Map.put(:image, img_handled)
    |> Map.put(:image_encoded, NFTHandler.encode_uri(img_handled, :svg))

  end

  @spec do_handle_svg(String.t(), String.t()) :: binary
  def do_handle_svg(img_parsed, base_url) do

    abstract_nft =
      img_parsed
      |> parser_svg()
    IO.puts inspect abstract_nft
      # |> insert_background(@resources)
    payload_svg =
      Enum.reduce(@resources, "", fn {key, payload}, svg_acc ->
        # exp. %{collection: [4], x: 1, y: 1, height: 500, width: 500}
        %{collection: collection, x: x, y: y, height: height, width: width} = payload
        value = Map.get(abstract_nft, key)
        IO.puts inspect value
        source =
          collection
          |> Enum.at(value - 1)
          |> handle_img_resource(base_url)


        svg_acc <> build_img_payload(source, x, y, height, width)
      end)

    result =
      img_parsed
      |> insert_payload_to_svg(@traits.n, payload_svg)
      |> replace_header()
      |> insert_white_rect()

    result
  end

  def replace_header(img) do
    String.replace(img, @header.origin, @header.replace)
  end

  def insert_white_rect(img) do
    {pos, _} = :binary.match(img, @traits.img)
    {bef, aft} = String.split_at(img, pos)
    bef <> @rect <> aft
  end


  def build_img_payload(nil, _x, _y, _height, _width), do: nil
  def build_img_payload(source, x, y, height, width) do
    "<image xlink:href='#{source}' "
    |> Kernel.<>("x='#{x}' y='#{y}' ")
    |> Kernel.<>("height='#{height}' width='#{width}' />")
  end


  # def insert_background(abstract_nft, %{background: _background}) do
  #   Map.put(abstract_nft, :background, 1)
  # end

  def parser_svg(img_parsed) do
    value =
      img_parsed
        |> String.split("class=\"base\">")
        |> Enum.drop(1)
        |> Enum.map(&(String.at(&1,0)))
        |> Enum.reject(&(Integer.parse(&1) == :error))
        |> Enum.map(&(String.to_integer(&1)))
    # value
    @keys
    |> Enum.zip(value)
    |> Enum.into(%{})
  end

  def handle_img_resource(unique_id, _base_url) when is_nil(unique_id) or (unique_id == 0), do: ""

  def handle_img_resource(unique_id, base_url) do
    source =
      unique_id
      |> id_to_source()

    base_url
    |> handle_url()
    |> Kernel.<>(source)
  end

  def insert_payload_to_svg(img_svg, trait, payload) do
    {position, _length} =  :binary.match(img_svg, trait)
    {payload_head, payload_tail}
      = String.split_at(img_svg, position)
    payload_head
    |> Kernel.<>(payload)
    |> Kernel.<>(payload_tail)
  end

  def handle_url(""), do: ""
  def handle_url(url) do
    if String.at(url, -1) == "/" do
      url
    else
      url <> "/"
    end
  end

  def id_to_source(unique_id), do: Map.get(@id_to_source, unique_id)

end
