defmodule Components.AiPic do

    use HTTPoison.Base
    @base "https://clipdrop-api.co"
    def text_to_image(txt) do
    end

    def client() do
        Tesla.client([
            # TODO: convert input/output type
            {Tesla.Middleware.BaseUrl, @base},
            {Tesla.Middleware.Headers, [{"x-api-key", Constants.clipdrop_key()}]}
        ])
    end
    def run do
         client() |>
         do_text_to_image("Draw a dancing dog")
      end
    def do_text_to_image(client, prompt) do
        mp = Tesla.Multipart.new()
            |> Tesla.Multipart.add_content_type_param("charset=utf-8")
            |> Tesla.Multipart.add_field("prompt", prompt,
              headers: [{"content-type", "text/plain"}]
            )
        Tesla.post(client, "/text-to-image/v1", mp)
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
