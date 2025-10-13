defmodule CamaraApi.Eventos do
  @doc """
  Fetches and formats a list of events from the Camara API.
  Returns a list of maps with clean, ready-to-use data for embeds.
  """

  @base_url "https://dadosabertos.camara.leg.br/api/v2"
  @finch Ryujin.Finch

  def fetch_and_format_events() do
    with {:ok, %{"dados" => events_data}} <- fetch_raw_events() do
      # Transform the raw data into a clean list of structs or maps
      formatted_events = Enum.map(events_data, &format_event/1)
      {:ok, formatted_events}
    else
      error -> error
    end
  end

  defp fetch_raw_events() do
    url = @base_url <> "/eventos"

    params = [
      {"dataInicio", "2025-10-01"},
      {"dataFim", "2025-10-10"},
      {"ordem", "ASC"},
      {"ordenarPor", "dataHoraInicio"}
    ]

    request = Finch.build(:get, url, [], "", opts: [query: params])

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

  defp format_event(event) do
    %{
      title: event["descricaoTipo"] || "Evento",
      description: event["descricao"] || "Sem descrição",
      start_time: event["dataHoraInicio"] || "N/A",
      location:
        Map.get(event, "localCamara", %{})["nome"] || Map.get(event, "localExterno") ||
          "Local Desconhecido",
      situation: event["situacao"] || "N/A",
      uri: event["uri"] || "https://dadosabertos.camara.leg.br",
      organs:
        case Map.get(event, "orgaos") do
          nil -> "N/A"
          organs_list -> Enum.map_join(organs_list, ", ", & &1["sigla"])
        end
    }
  end
end
