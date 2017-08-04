defmodule Livegames.WebClient do
    @callback get!(url :: String.t) :: %HTTPoison.Response{}
end

defmodule Livegames.HTTPoisonWebClient do
    def get!(url) do
        HTTPoison.get!(url)
    end
end