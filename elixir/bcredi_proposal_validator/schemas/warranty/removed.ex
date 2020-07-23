defmodule Warranty.Removed do
  @moduledoc """
  Warranty.Removed Schema
  """
  @type event_id :: String.t()
  @type event_schema :: atom()
  @type event_action :: atom()
  @type event_timestamp :: String.t()
  @type proposal_id :: String.t()
  @type warranty_id :: String.t()

  defstruct [
    :event_id,
    :event_timestamp,
    :proposal_id,
    :warranty_id,
    event_schema: :warranty,
    event_action: :removed
  ]
end
