defmodule Ryujin.Speech do
    # Mudar isso para o servidor da Providentia
    @base_url "http://0.0.0.0:8000/speech/"
    @finch Ryujin.Finch


    def answer_quickly(message) do
      {:ok, responseStruct} = get_simple_response(message)
      create_message_embed(responseStruct["response"])
    end

    defp create_message_embed(message_string) do
      embed_payload = %Nostrum.Struct.Embed{
      title: "Clairemont responds...",
      description: message_string,
      color: 14_423_100,
      footer: %Nostrum.Struct.Embed.Footer
      {
        text: "Powered by PROVIDENCE."
      }
      }

      embed_payload
    end

    defp get_simple_response(message) do
        url = @base_url <> "simple_response"
        headers = [{"content-type", "application/json"}]
        request_body = Jason.encode!(%{prompt: message})
        request = Finch.build(:post, url, headers, request_body)

  # Needs a huge timout in case Providentia overthinks
  case Finch.request(request, @finch, receive_timeout: 200_000) do
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
