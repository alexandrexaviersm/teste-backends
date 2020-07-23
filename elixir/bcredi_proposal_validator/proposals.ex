Code.require_file("./bcredi_proposal_validator/schemas/proposal_model.ex")

defmodule Proposals do
  @moduledoc """
  Proposals Public API
  """
  def create_proposal_model(proposal_model_list, event_struct) do
    proposal_model = %ProposalModel{
      proposal_id: event_struct.proposal_id,
      events_received: [event_struct]
    }

    event_attrs_to_validate = mount_attrs_to_validate(event_struct)

    updated_proposal_model =
      merge_event_attrs_in_proposal_model(proposal_model, event_attrs_to_validate)

    [updated_proposal_model | proposal_model_list]
  end

  defp merge_event_attrs_in_proposal_model(proposal_model, event_attrs_to_validate) do
    Map.merge(proposal_model, event_attrs_to_validate)
  end

  defp mount_attrs_to_validate(event_struct),
    do: %{
      proposal_loan_value: event_struct.proposal_loan_value,
      proposal_number_of_monthly_installments:
        event_struct.proposal_number_of_monthly_installments
    }
end
