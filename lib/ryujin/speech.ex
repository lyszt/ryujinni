defmodule Ryujin.Speech do
    # Mudar isso para o servidor da Providentia
    @base_url "http://0.0.0.0:8000/speech/"
    @finch Ryujin.Finch


    def answer_quickly(message) do
      response = get_simple_response(message.response)
      response
    end

    defp get_simple_response(message) do
        url = @base_url <> "simple_response"
        headers = [{"content-type", "application/json"}]
        request_body = Jason.encode!(%{prompt: message})
        request = Finch.build(:post, url, headers, request_body)

        case Finch.request(request, @finch) do
        {:ok, %Finch.Response{status: 200, body: body}} ->
          case Jason.decode(body, keys: :strings) do
            {:ok, data} -> {:ok, data}
            {:error, reason} -> {:error, "JSON decoding failed: #{inspect(reason)}"}
          end

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, "API returned status #{status} with body: #{body}"}

      {:error, reason} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
    end
end
