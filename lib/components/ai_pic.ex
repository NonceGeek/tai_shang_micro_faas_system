defmodule Components.AiPic do

    alias Tesla.Multipart

    @base "https://clipdrop-api.co"

    def client() do
        Tesla.client([
            # TODO: convert input/output type
            {Tesla.Middleware.BaseUrl, @base},
            {Tesla.Middleware.Headers, [{"x-api-key", Constants.clipdrop_key()}]}
        ])
    end

    # +-------------+
    # | text to img |
    # +-------------+

    def text_to_image(prompt) do
        client = client()
        file_name =  do_text_to_image(client, prompt)
        "images/#{file_name}.png"
    end

    def do_text_to_image(client, prompt) do
        mp = Multipart.new()
            |> Multipart.add_content_type_param("charset=utf-8")
            |> Multipart.add_field("prompt", prompt,
              headers: [{"content-type", "text/plain"}]
            )
        {:ok, %{body: img_raw}} =
            Tesla.post(client, "/text-to-image/v1", mp)
        file_name = RandGen.gen_hex(10)
        File.write("priv/static/images/#{file_name}.png", img_raw)
        file_name
    end

    # +---------------+
    # | sketch to img |
    # +---------------+
    # TODO: some type of pics are not working, waiting the guys to fix it.
    def sketch_to_image(file_url, prompt) do
        client = client()
        file_name = do_sketch_to_image(client, file_url, prompt)
        "images/#{file_name}.png"
    end

    def do_sketch_to_image(client, file_url, prompt) do
        # TODO: download the file to the local.
        mp = Tesla.Multipart.new()
            |> Tesla.Multipart.add_field("prompt", prompt,
              headers: [{"content-type", "text/plain"}]
            )
            |> Multipart.add_file(
                "priv/static/images/sketch_example.png", name: "sketch_file") # TODO: update here.
        {:ok, %{body: img_raw}} =
            Tesla.post(client, "/sketch-to-image/v1/sketch-to-image/", mp)
        file_name = RandGen.gen_hex(10)
        File.write("priv/static/images/#{file_name}.png", img_raw)
        file_name
    end

    # +-------------------+
    # | reimagine the img |
    # +-------------------+

    def reimagine(file_url) do
        client = client()
        file_name = do_reimagine(client, file_url)
        "images/#{file_name}.png"
    end

    def do_reimagine(client, file_url) do
        mp = Tesla.Multipart.new()
            |> Multipart.add_file(
                "priv/static/images/sketch_example.png",  # TODO: update here.
                name: "image_file"
            ) 

        {:ok, %{body: img_raw}} =
            Tesla.post(client, "/reimagine/v1/reimagine/", mp)
        file_name = RandGen.gen_hex(10)
        File.write("priv/static/images/#{file_name}.png", img_raw)
        file_name
    end

end
