defmodule ProposalModel do
  @moduledoc """
  ProposalModel Schema
  """
  @type proposal_id :: String.t()
  @type proposal_loan_value :: float()
  @type proposal_number_of_monthly_installments :: integer()
  @type events :: list()
  @type proponents :: list()
  @type warranties :: list()

  defstruct [
    :proposal_id,
    :proposal_loan_value,
    :proposal_number_of_monthly_installments,
    :events,
    proponents: [],
    warranties: []
  ]
end
