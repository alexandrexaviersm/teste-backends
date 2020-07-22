defmodule Proponent.Updated do
  @type event_id :: String.t()
  @type event_schema :: atom()
  @type event_action :: atom()
  @type event_timestamp :: String.t()
  @type proposal_id :: String.t()
  @type proponent_id :: String.t()
  @type proponent_name :: String.t()
  @type proponent_age :: integer()
  @type proponent_monthly_income :: float()
  @type proponent_is_main :: atom()

  defstruct [
    :event_id,
    :event_timestamp,
    :proposal_id,
    :proponent_id,
    :proponent_name,
    :proponent_age,
    :proponent_monthly_income,
    :proponent_is_main,
    event_schema: :proponent,
    event_action: :updated
  ]
end
