Code.require_file("./event.ex")
Code.require_file("./validations.ex")

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
        event_struct =
          generate_event_attrs(event)
          |> Event.mount_event_in_struct()

        existing_proposal_event =
          Enum.find(proposal_model_list, &(&1.proposal_id == event_struct.proposal_id))

        Event.create_proposal_model_or_merge_event(
          existing_proposal_event,
          proposal_model_list,
          event_struct
        )
      end)

    proposal_models
    |> Validations.check_for_valid_proposals()
    |> Enum.filter(& &1)
    |> Enum.reverse()
    |> Enum.join(",")
  end

  defp generate_event_attrs(event) do
    event_attrs = String.split(event, ",")
    event_schema = Enum.at(event_attrs, 1)
    event_action = Enum.at(event_attrs, 2)

    %{event_schema: event_schema, event_action: event_action, event_attrs: event_attrs}
  end
end
