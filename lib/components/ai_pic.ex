defmodule Components.AiPic do

    
    use HTTPoison.Base
    @base "https://clipdrop-api.co"

    def text_to_image(txt) do
    end

    def client() do
        Tesla.client([
            # TODO: convert input/output type
            {Tesla.Middleware.BaseUrl, @base},
            {Tesla.Middleware.Headers, [{"x-api-key", Constants.clipdrop_key()}]},
            # {Tesla.Middleware.EncodeFormUrlencoded}
        ])
    end

    def do_text_to_image(_client, prompt) do
        mp =
            Tesla.Multipart.new()
            |> Tesla.Multipart.add_field("prompt", prompt)

        # Tesla.post(client, "/text-to-image/v1", mp)
        {:ok, %{body: img_raw}} =
            Tesla.post(
                "https://clipdrop-api.co/text-to-image/v1", 
                mp, 
                headers: [{"x-api-key", Constants.clipdrop_key()}]
            )
         # Save file
        file_name = RandGen.gen_hex(10)
        File.write("pic_generated/#{file_name}.png", img_raw)
        file_name
        # response the link
    end
    # def do_text_to_image(txt) do
    #     IO.puts inspect Constants.clipdrop_key()
    #     body = "prompt=#{txt}"
    #     heads = 
    #         [{"Content-Type", "text/plain"}, {"x-api-key", Constants.clipdrop_key()}]
    #     IO.puts inspect heads
    #     ExHttp.http_post(@api.text_to_image, body, heads, 3)
    # end

    # def do_text_to_image(prompt, output_file) do
    #     headers = [
    #         {"x-api-key", Constants.clipdrop_key()},
    #         {"Content-Type", "text/plain"}
    #     ]

    #     body = 
    #         "prompt=#{prompt}"

    #     response = post!(
    #         @api.text_to_image, 
    #         {headers, :multipart, body}
    #     )
    #         # [:file, output_file])
    #     {:ok, response}
    # end

end