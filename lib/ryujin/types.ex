defmodule Ryujin.Types do
  @moduledoc """
  Shared types for Ryujinni.
  """

  @type activity() ::
          {:playing, String.t()}
          | {:streaming, String.t(), String.t()}
          | {:listening, String.t()}
          | {:watching, String.t()}
          | {:competing, String.t()}
end
