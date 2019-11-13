defmodule GlassFactoryApi.ApiClient do
  @moduledoc """
  Client which make external HTTP Request.
  """
  alias GlassFactoryApi.Configuration

  @doc """
  Make a GET request using the given configuration to retrieve the given resource.

  ## Examples
      iex> GlassFactoryApi.ApiClient.get("members")
      {:ok , %{body: "[]", headers: [], status_code: 200}}

  If no configuration is passed, it will look for them in `Configuration.build\\1`
  """

  @spec get(String.t(), map()) :: Tesla.Env.t()
  def get(resource, configuration) do
    config = Configuration.build(configuration)

    Tesla.get(tesla_client(config), resource)
  end

  defp tesla_client(configuration) do
    middlewares = [
      {Tesla.Middleware.Headers, headers(configuration)},
      {Tesla.Middleware.BaseUrl, url(configuration)},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middlewares)
  end

  defp headers(configuration) do
    # NOTE: We have to accept "text/plain" because when GlassFactory API returns
    # a 404 status code, it sends an invalid JSON that has JSON content-type,
    # which causes a decode error in `Tesla.Middleware.JSON`.
    [
      {"X-Account-Subdomain", configuration[:subdomain]},
      {"X-User-Token", configuration[:user_token]},
      {"X-User-Email", configuration[:user_email]},
      {"Accept", "text/plain, application/json"}
    ]
  end

  defp url(configuration) do
    "#{configuration[:api_url]}/api/public/v1/"
  end
end
