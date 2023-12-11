defmodule Components.AiPic do

    @api %{text_to_image: "https://clipdrop-api.co/text-to-image/v1"}
    alias  Components.ExHttp
    def text_to_image(txt) do
    end

    def do_text_to_image(txt) do
        IO.puts inspect Constants.clipdrop_key()
        body = "prompt=#{txt}"
        heads = 
            [{"Content-Type", "text/plain"}, {"x-api-key", Constants.clipdrop_key()}]
        IO.puts inspect heads
        ExHttp.http_post(@api.text_to_image, body, heads, 3)
    end
end