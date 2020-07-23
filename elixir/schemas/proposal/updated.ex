defmodule Proposal.Updated do
  @moduledoc """
  Proposal.Updated Schema
  """
  @type event_id :: String.t()
  @type event_schema :: atom()
  @type event_action :: atom()
  @type event_timestamp :: String.t()
  @type proposal_id :: String.t()
  @type proposal_loan_value :: float()
  @type proposal_number_of_monthly_installments :: integer()

  defstruct [
    :event_id,
    :event_timestamp,
    :proposal_id,
    :proposal_loan_value,
    :proposal_number_of_monthly_installments,
    event_schema: :proposal,
    event_action: :updated
  ]
end
