Code.require_file("./schemas/proposal_model.ex")
Code.require_file("./validations.ex")

Path.wildcard("schemas/*/*.ex")
|> Enum.map(&Code.require_file/1)

defmodule Solution do
  @moduledoc """
  Essa função recebe uma lista de mensagens, por exemplo:

  [
    "72ff1d14-756a-4549-9185-e60e326baf1b,proposal,created,2019-11-11T14:28:01Z,80921e5f-4307-4623-9ddb-5bf826a31dd7,1141424.0,240",
    "af745f6d-d5c0-41e9-b04f-ee524befa425,warranty,added,2019-11-11T14:28:01Z,80921e5f-4307-4623-9ddb-5bf826a31dd7,31c1dd83-8fb7-44ff-8cb7-947e604f6293,3245356.0,DF",
    "450951ee-a38d-475c-ac21-f22b4566fb29,warranty,added,2019-11-11T14:28:01Z,80921e5f-4307-4623-9ddb-5bf826a31dd7,c8753500-1982-4003-8287-3b46c75d4803,3413113.45,DF",
    "66882b68-baa4-47b1-9cc7-7db9c2d8f823,proponent,added,2019-11-11T14:28:01Z,80921e5f-4307-4623-9ddb-5bf826a31dd7,3f52890a-7e9a-4447-a19b-bb5008a09672,Ismael Streich Jr.,42,62615.64,true"
  ]

  Complete a função para retornar uma string com os IDs das propostas válidas no seguinte formato (separado por vírgula):
  "52f0b3f2-f838-4ce2-96ee-9876dd2c0cf6,51a41350-d105-4423-a9cf-5a24ac46ae84,50cedd7f-44fd-4651-a4ec-f55c742e3477"
  """

  def process_messages(events) do
    proposal_models =
      Enum.reduce(events, [], fn event, proposal_model_list ->
        event_attrs = String.split(event, ",")
        event_schema = Enum.at(event_attrs, 1)
        event_action = Enum.at(event_attrs, 2)

        event_struct = create_event_struct(event_schema, event_action, event_attrs)

        existing_proposal_event =
          Enum.find(proposal_model_list, fn proposal_model ->
            proposal_model.proposal_id == event_struct.proposal_id
          end)

        case existing_proposal_event do
          nil ->
            create_proposal_model(proposal_model_list, event_struct)

          # antes de colocar na lista
          _ ->
            # Em caso de eventos repetidos, considere o primeiro evento
            # Por exemplo, ao receber o evento ID 1 e novamente o mesmo evento, descarte o segundo evento

            # Em caso de eventos atrasados, considere sempre o evento mais novo
            # Por exemplo, ao receber dois eventos de atualização com IDs diferentes, porém o último evento tem um timestamp mais antigo do que o primeiro, descarte o evento mais antigo

            merge_or_reject_event_of_existing_proposal(
              proposal_model_list,
              existing_proposal_event,
              event_struct
            )

            # warranty_removed
        end
      end)

    valid_proposals_ids =
      Enum.map(proposal_models, fn proposal_model ->
        with true <- Validations.validate_value_of_proposal_loan(proposal_model),
             true <- Validations.validate_number_of_monthly_installments(proposal_model),
             true <- Validations.validate_minimum_number_of_proponents(proposal_model),
             true <- Validations.validate_has_one_main_proponent(proposal_model),
             true <- Validations.validate_proponents_age(proposal_model),
             true <- Validations.validate_has_at_least_one_warranty(proposal_model),
             true <- Validations.validate_warranties_values(proposal_model),
             true <- Validations.validate_main_proponent_monthly_income(proposal_model) do
          proposal_model.proposal_id
        end
      end)

    valid_proposals_ids |> Enum.filter(& &1) |> Enum.reverse() |> Enum.join(",")
  end

  defp create_event_struct("proposal", "created", event) do
    %Proposal.Created{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      proposal_loan_value: Enum.at(event, 5) |> String.to_float(),
      proposal_number_of_monthly_installments: Enum.at(event, 6) |> String.to_integer()
    }
  end

  defp create_event_struct("proposal", "updated", event) do
    %Proposal.Updated{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      proposal_loan_value: Enum.at(event, 5) |> String.to_float(),
      proposal_number_of_monthly_installments: Enum.at(event, 6) |> String.to_integer()
    }
  end

  defp create_event_struct("proposal", "deleted", event) do
    %Proposal.Deleted{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4)
    }
  end

  defp create_event_struct("warranty", "added", event) do
    %Warranty.Added{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      warranty_id: Enum.at(event, 5),
      warranty_value: Enum.at(event, 6) |> String.to_float(),
      warranty_province: Enum.at(event, 7)
    }
  end

  defp create_event_struct("warranty", "updated", event) do
    %Warranty.Updated{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      warranty_id: Enum.at(event, 5),
      warranty_value: Enum.at(event, 6) |> String.to_float(),
      warranty_province: Enum.at(event, 7)
    }
  end

  defp create_event_struct("warranty", "removed", event) do
    %Warranty.Removed{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      warranty_id: Enum.at(event, 5)
    }
  end

  defp create_event_struct("proponent", "added", event) do
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

  defp create_event_struct("proponent", "updated", event) do
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

  defp create_event_struct("proponent", "removed", event) do
    %Proponent.Removed{
      event_id: Enum.at(event, 0),
      event_timestamp: Enum.at(event, 3),
      proposal_id: Enum.at(event, 4),
      proponent_id: Enum.at(event, 5)
    }
  end

  defp mount_attrs_to_validate(event_struct) do
    case event_struct do
      %Proposal.Created{} ->
        %{
          proposal_loan_value: event_struct.proposal_loan_value,
          proposal_number_of_monthly_installments:
            event_struct.proposal_number_of_monthly_installments
        }

      %Warranty.Added{} ->
        %{
          warranty_value: event_struct.warranty_value,
          warranty_province: event_struct.warranty_province
        }

      %Proponent.Added{} ->
        %{
          proponent_age: event_struct.proponent_age,
          proponent_monthly_income: event_struct.proponent_monthly_income,
          proponent_is_main: event_struct.proponent_is_main
        }

      _ ->
        %{}
    end
  end

  defp create_proposal_model(proposal_model_list, event_struct) do
    proposal_model = %ProposalModel{
      proposal_id: event_struct.proposal_id,
      events: [event_struct]
    }

    event_attrs_to_validate = mount_attrs_to_validate(event_struct)

    updated_proposal_model =
      merge_event_attrs_in_proposal_model(proposal_model, event_attrs_to_validate)

    [updated_proposal_model | proposal_model_list]
  end

  @doc """
  Property Warranties of the states PR, SC and RS aren't accepted
  """
  defp merge_or_reject_event_of_existing_proposal(
         proposal_model_list,
         _existing_proposal_event,
         %Warranty.Added{
           warranty_province: warranty_province
         }
       )
       when warranty_province in ~w(PR SC RS) do
    proposal_model_list
  end

  defp merge_or_reject_event_of_existing_proposal(
         proposal_model_list,
         existing_proposal_event,
         %Warranty.Added{} = event_struct
       ) do
    event_attrs_to_validate = mount_attrs_to_validate(event_struct)

    prepare_attrs = %{
      warranties: existing_proposal_event.warranties ++ [event_attrs_to_validate],
      events: existing_proposal_event.events ++ [event_struct]
    }

    updated_proposal_model =
      merge_event_attrs_in_proposal_model(existing_proposal_event, prepare_attrs)

    updated_proposal_model_list = List.delete(proposal_model_list, existing_proposal_event)

    [updated_proposal_model | updated_proposal_model_list]
  end

  defp merge_or_reject_event_of_existing_proposal(
         proposal_model_list,
         existing_proposal_event,
         %Proponent.Added{} = event_struct
       ) do
    event_attrs_to_validate = mount_attrs_to_validate(event_struct)

    prepare_attrs = %{
      proponents: existing_proposal_event.proponents ++ [event_attrs_to_validate],
      events: existing_proposal_event.events ++ [event_struct]
    }

    updated_proposal_model =
      merge_event_attrs_in_proposal_model(existing_proposal_event, prepare_attrs)

    updated_proposal_model_list = List.delete(proposal_model_list, existing_proposal_event)

    [updated_proposal_model | updated_proposal_model_list]
  end

  defp merge_event_attrs_in_proposal_model(proposal_model, event_attrs_to_validate) do
    Map.merge(proposal_model, event_attrs_to_validate)
  end
end
