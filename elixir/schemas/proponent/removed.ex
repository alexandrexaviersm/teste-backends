defmodule Proponent.Removed do
  @moduledoc """
  Proponent.Removed
  """
  @type event_id :: String.t()
  @type event_schema :: atom()
  @type event_action :: atom()
  @type event_timestamp :: String.t()
  @type proposal_id :: String.t()
  @type proponent_id :: String.t()

  defstruct [
    :event_id,
    :event_timestamp,
    :proposal_id,
    :proponent_id,
    event_schema: :proponent,
    event_action: :removed
  ]
end
