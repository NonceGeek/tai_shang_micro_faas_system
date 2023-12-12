defmodule Components.AiPic do

    use HTTPoison.Base
    @base "https://clipdrop-api.co"
    def text_to_image(prompt) do
        client = client()
        file_name =  do_text_to_image(client, prompt)
        file_name
    end

    def client() do
        Tesla.client([
            # TODO: convert input/output type
            {Tesla.Middleware.BaseUrl, @base},
            {Tesla.Middleware.Headers, [{"x-api-key", Constants.clipdrop_key()}]}
        ])
    end

    def do_text_to_image(client, prompt) do
        mp = Tesla.Multipart.new()
            |> Tesla.Multipart.add_content_type_param("charset=utf-8")
            |> Tesla.Multipart.add_field("prompt", prompt,
              headers: [{"content-type", "text/plain"}]
            )
        {:ok, %{body: img_raw}} =
            Tesla.post(client, "/text-to-image/v1", mp)
        file_name = RandGen.gen_hex(10)
        File.write("pic_generated/#{file_name}.png", img_raw)
        file_name
    end

end
