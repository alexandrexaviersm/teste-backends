defmodule Proposal.Deleted do
  @moduledoc """
  Proposal.Deleted Schema
  """
  @type event_id :: String.t()
  @type event_schema :: atom()
  @type event_action :: atom()
  @type event_timestamp :: String.t()
  @type proposal_id :: String.t()

  defstruct [
    :event_id,
    :event_timestamp,
    :proposal_id,
    event_schema: :proposal,
    event_action: :deleted
  ]
end
