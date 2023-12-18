defmodule Components.ExHttp do
  @retries 5
  @default_user_agent "faas"

  require Logger

  def http_get(url) do
    http_get(url, @retries)
  end

  def http_get(_url, retries) when retries == 0 do
    {:error, "GET retires #{@retries} times and not success"}
  end

  def http_get(url, retries) do
    url
    |> HTTPoison.get([{"User-Agent", @default_user_agent}],
      hackney: [headers: [{"User-Agent", @default_user_agent}]]
    )
    |> handle_response()
    |> case do
      {:ok, body} ->
        {:ok, body}

      {:error, 404} ->
        {:error, 404}
      {:error, _} ->
        Process.sleep(500)
        http_get(url, retries - 1)
    end
  end

  def http_post(url, data) do
    http_post(url, data, @retries)
  end

  def http_post(_url, _data, retries) when retries == 0 do
    {:error, "POST retires #{@retries} times and not success"}
  end

  # def http_post(_url, _data, _, retries) when retries == 0 do
  #   {:error, "POST retires #{@retries} times and not success"}
  # end

  # def http_post(url, data, heads, retries) do
  #   body = Poison.encode!(data)

  #   url
  #   |> HTTPoison.post(
  #     body,
  #     # [{"User-Agent", @default_user_agent}, {"Content-Type", "text/plain"}]
  #     heads,
  #     hackney: [headers: [{"User-Agent", @default_user_agent}]]
  #   )
  #   |> handle_response()
  #   |> case do
  #     {:ok, body} ->
  #       {:ok, body}
  #     {:error, 404} ->
  #       {:error, 404}
  #     {:error, _} ->
  #       Process.sleep(500)
  #       http_post(url, data, heads, retries - 1)
  #   end
  # end

  def http_post(url, data, retries) do
    body = Poison.encode!(data)

    url
    |> HTTPoison.post(
      body,
      [{"User-Agent", @default_user_agent}, {"Content-Type", "application/json"}],
      hackney: [headers: [{"User-Agent", @default_user_agent}]]
    )
    |> handle_response()
    |> case do
      {:ok, body} ->
        {:ok, body}
      {:error, 404} ->
        {:error, 404}
      {:error, _} ->
        Process.sleep(500)
        http_post(url, data, retries - 1)
    end
  end

  # normal
  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}})
       when status_code in 200..299 do
    case Poison.decode(body) do
      {:ok, json_body} ->
        {:ok, ExStructTranslator.to_atom_struct(json_body)}

      {:error, payload} ->
        Logger.error("Reason: #{inspect(payload)}")
        {:error, :network_error}
    end
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 404, body: _}}) do
    Logger.error("Reason: 404")
    {:error, 404}
  end
  # else
  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: _}}) do
    Logger.error("Reason: #{status_code} ")
    {:error, :network_error}
  end

  defp handle_response(error) do
    Logger.error("Reason: other_error")
    error
  end

  def http_get(_url, _token, retries) when retries == 0 do
    {:error, "GET retires #{@retries} times and not success"}
  end

  def http_get(url, token, retries) do
    url
    |> HTTPoison.get(
      [
        {"User-Agent", @default_user_agent},
        {"authorization", "Bearer #{token}"}
      ],
      hackney: [
        headers: [
          {"User-Agent", @default_user_agent}
        ]
    ]
    )
    |> handle_response()
    |> case do
      {:ok, body} ->
        {:ok, body}

      {:error, 404} ->
        {:error, 404}
      {:error, _} ->
        Process.sleep(500)
        http_get(url, token, retries - 1)
    end
  end

  def http_post(_url, _data, _token, retries) when retries == 0 do
    {:error, "POST retires #{@retries} times and not success"}
  end

  def http_post(url, data, token, retries) do
    body = Poison.encode!(data)
    url
    |> HTTPoison.post(
      body,
      [
        {"User-Agent", @default_user_agent},
        {"Content-Type", "application/json"},
        {"authorization", "Bearer #{token}"}
      ],
      hackney: [headers: [{"User-Agent", @default_user_agent}]]
    )
    |> handle_response()
    |> case do
      {:ok, body} ->
        {:ok, body}
      {:error, 404} ->
        {:error, 404}
      {:error, _} ->
        Process.sleep(1000)
        http_post(url, data, token, retries - 1)
    end
  end

  
end
