Code.require_file("./bcredi_proposal_validator/proponents.ex")
Code.require_file("./bcredi_proposal_validator/proposals.ex")
Code.require_file("./bcredi_proposal_validator/warranties.ex")

Path.wildcard("./bcredi_proposal_validator/schemas/*/*.ex")
|> Enum.map(&Code.require_file/1)

defmodule Event do
  def create_proposal_model_or_merge_event(nil, proposal_model_list, event_struct) do
    Proposals.create_proposal_model(proposal_model_list, event_struct)
  end

  def create_proposal_model_or_merge_event(
        existing_proposal_event,
        proposal_model_list,
        event_struct
      ) do
    merge_or_reject_event_of_existing_proposal(
      proposal_model_list,
      existing_proposal_event,
      event_struct
    )
  end

  def mount_event_in_struct(%{
        event_schema: "proposal",
        event_action: "created",
        event_attrs: event
      }) do
    %Proposal.Created{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      proposal_loan_value: Enum.at(event, 5) |> String.to_float(),
      proposal_number_of_monthly_installments: Enum.at(event, 6) |> String.to_integer()
    }
  end

  def mount_event_in_struct(%{
        event_schema: "proposal",
        event_action: "updated",
        event_attrs: event
      }) do
    %Proposal.Updated{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      proposal_loan_value: Enum.at(event, 5) |> String.to_float(),
      proposal_number_of_monthly_installments: Enum.at(event, 6) |> String.to_integer()
    }
  end

  def mount_event_in_struct(%{
        event_schema: "proposal",
        event_action: "deleted",
        event_attrs: event
      }) do
    %Proposal.Deleted{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4)
    }
  end

  def mount_event_in_struct(%{
        event_schema: "warranty",
        event_action: "added",
        event_attrs: event
      }) do
    %Warranty.Added{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      warranty_id: Enum.at(event, 5),
      warranty_value: Enum.at(event, 6) |> String.to_float(),
      warranty_province: Enum.at(event, 7)
    }
  end

  def mount_event_in_struct(%{
        event_schema: "warranty",
        event_action: "updated",
        event_attrs: event
      }) do
    %Warranty.Updated{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      warranty_id: Enum.at(event, 5),
      warranty_value: Enum.at(event, 6) |> String.to_float(),
      warranty_province: Enum.at(event, 7)
    }
  end

  def mount_event_in_struct(%{
        event_schema: "warranty",
        event_action: "removed",
        event_attrs: event
      }) do
    %Warranty.Removed{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      warranty_id: Enum.at(event, 5)
    }
  end

  def mount_event_in_struct(%{
        event_schema: "proponent",
        event_action: "added",
        event_attrs: event
      }) do
    %Proponent.Added{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      proponent_id: Enum.at(event, 5),
      proponent_name: Enum.at(event, 6),
      proponent_age: Enum.at(event, 7) |> String.to_integer(),
      proponent_monthly_income: Enum.at(event, 8) |> String.to_float(),
      proponent_is_main: Enum.at(event, 9) |> String.to_atom()
    }
  end

  def mount_event_in_struct(%{
        event_schema: "proponent",
        event_action: "updated",
        event_attrs: event
      }) do
    %Proponent.Updated{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      proponent_id: Enum.at(event, 5),
      proponent_name: Enum.at(event, 6),
      proponent_age: Enum.at(event, 7) |> String.to_integer(),
      proponent_monthly_income: Enum.at(event, 8) |> String.to_float(),
      proponent_is_main: Enum.at(event, 9) |> String.to_atom()
    }
  end

  def mount_event_in_struct(%{
        event_schema: "proponent",
        event_action: "removed",
        event_attrs: event
      }) do
    %Proponent.Removed{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      proponent_id: Enum.at(event, 5)
    }
  end

  defp merge_or_reject_event_of_existing_proposal(
         proposal_model_list,
         existing_proposal_event,
         %{event_schema: :warranty} = event_struct
       ) do
    Warranties.handle_event(proposal_model_list, existing_proposal_event, event_struct)
  end

  defp merge_or_reject_event_of_existing_proposal(
         proposal_model_list,
         existing_proposal_event,
         %{event_schema: :proponent} = event_struct
       ) do
    Proponents.handle_event(proposal_model_list, existing_proposal_event, event_struct)
  end
end
