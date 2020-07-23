Path.wildcard("./bcredi_proposal_validator/schemas/proponent/*.ex")
|> Enum.map(&Code.require_file/1)

defmodule Proponents do
  @moduledoc """
  Proponents Public API
  """

  def handle_event(
        proposal_model_list,
        existing_proposal_event,
        %Proponent.Added{} = event_struct
      ) do
    case check_repeated_events(existing_proposal_event, event_struct) do
      nil ->
        event_attrs_to_validate = mount_attrs_to_validate(event_struct)

        prepare_attrs = %{
          proponents: existing_proposal_event.proponents ++ [event_attrs_to_validate],
          events_received: existing_proposal_event.events_received ++ [event_struct]
        }

        updated_proposal_model =
          merge_event_attrs_in_proposal_model(existing_proposal_event, prepare_attrs)

        updated_proposal_model_list = List.delete(proposal_model_list, existing_proposal_event)

        [updated_proposal_model | updated_proposal_model_list]

      _ ->
        proposal_model_list
    end
  end

  def handle_event(
        proposal_model_list,
        existing_proposal_event,
        %Proponent.Updated{} = event_struct
      ) do
    case check_repeated_events(existing_proposal_event, event_struct) do
      nil ->
        proponents =
          Enum.reject(existing_proposal_event.proponents, fn proponent ->
            proponent.proponent_id == event_struct.proponent_id
          end)

        updated_proposal_model =
          merge_event_attrs_in_proposal_model(existing_proposal_event, %{proponents: proponents})

        event_attrs_to_validate = mount_attrs_to_validate(event_struct)

        prepare_attrs = %{
          proponents: updated_proposal_model.proponents ++ [event_attrs_to_validate],
          events_received: updated_proposal_model.events_received ++ [event_struct]
        }

        updated_proposal_model =
          merge_event_attrs_in_proposal_model(existing_proposal_event, prepare_attrs)

        updated_proposal_model_list = List.delete(proposal_model_list, existing_proposal_event)

        [updated_proposal_model | updated_proposal_model_list]

      _ ->
        proposal_model_list
    end
  end

  defp check_repeated_events(%{events_received: events_received}, %{event_id: event_id}) do
    Enum.find(events_received, &(&1.event_id == event_id))
  end

  defp merge_event_attrs_in_proposal_model(proposal_model, event_attrs_to_validate) do
    Map.merge(proposal_model, event_attrs_to_validate)
  end

  defp mount_attrs_to_validate(event_struct),
    do: %{
      proponent_id: event_struct.proponent_id,
      proponent_age: event_struct.proponent_age,
      proponent_monthly_income: event_struct.proponent_monthly_income,
      proponent_is_main: event_struct.proponent_is_main
    }
end
