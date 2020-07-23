Path.wildcard("./bcredi_proposal_validator/schemas/warranty/*.ex")
|> Enum.map(&Code.require_file/1)

defmodule Warranties do
  @moduledoc """
  Warranties Public API
  """

  @doc """
  Property Warranties of the states PR, SC and RS aren't accepted
  """
  def handle_event(
        proposal_model_list,
        _existing_proposal_event,
        %Warranty.Added{
          warranty_province: warranty_province
        }
      )
      when warranty_province in ~w(PR SC RS) do
    proposal_model_list
  end

  def handle_event(
        proposal_model_list,
        existing_proposal_event,
        %Warranty.Added{} = event_struct
      ) do
    case check_repeated_events(existing_proposal_event, event_struct) do
      nil ->
        event_attrs_to_validate = mount_attrs_to_validate(event_struct)

        prepare_attrs = %{
          warranties: existing_proposal_event.warranties ++ [event_attrs_to_validate],
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
        %Warranty.Removed{} = event_struct
      ) do
    case check_repeated_events(existing_proposal_event, event_struct) do
      nil ->
        warranties =
          Enum.reject(existing_proposal_event.warranties, fn warranty ->
            warranty.warranty_id == event_struct.warranty_id
          end)

        updated_proposal_model =
          merge_event_attrs_in_proposal_model(existing_proposal_event, %{warranties: warranties})

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
      warranty_id: event_struct.warranty_id,
      warranty_value: event_struct.warranty_value,
      warranty_province: event_struct.warranty_province
    }
end
