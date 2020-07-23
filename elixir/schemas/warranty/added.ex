defmodule Warranty.Added do
  @moduledoc """
  Warranty.Added Schema
  """
  @type event_id :: String.t()
  @type event_schema :: atom()
  @type event_action :: atom()
  @type event_timestamp :: String.t()
  @type proposal_id :: String.t()
  @type warranty_id :: String.t()
  @type warranty_value :: float()
  @type warranty_province :: String.t()

  defstruct [
    :event_id,
    :event_timestamp,
    :proposal_id,
    :warranty_id,
    :warranty_value,
    :warranty_province,
    event_schema: :warranty,
    event_action: :added
  ]
end
