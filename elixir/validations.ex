defmodule Validations do
  @moduledoc """

  """
  def validate_value_of_proposal_loan(%ProposalModel{proposal_loan_value: proposal_loan_value}) do
    proposal_loan_value >= 30_000.0 && proposal_loan_value <= 3_000_000.0
  end

  def validate_number_of_monthly_installments(%ProposalModel{
        proposal_number_of_monthly_installments: proposal_number_of_monthly_installments
      }) do
    proposal_number_of_monthly_installments >= 24 &&
      proposal_number_of_monthly_installments <= 180
  end

  def validate_minimum_number_of_proponents(%ProposalModel{proponents: proponents}) do
    length(proponents) >= 2
  end

  def validate_has_one_main_proponent(%ProposalModel{proponents: proponents}) do
    Enum.filter(proponents, & &1.proponent_is_main)
    |> length()
    |> Kernel.==(1)
  end

  def validate_proponents_age(%ProposalModel{proponents: proponents}) do
    Enum.all?(proponents, &(&1.proponent_age >= 18))
  end

  def validate_has_at_least_one_warranty(%ProposalModel{warranties: warranties}) do
    length(warranties) >= 2
  end

  def validate_warranties_values(%ProposalModel{
        proposal_loan_value: proposal_loan_value,
        warranties: warranties
      }) do
    sum_of_warranties_values =
      Enum.reduce(warranties, 0, fn %{warranty_value: warranty_value}, acc ->
        warranty_value + acc
      end)

    sum_of_warranties_values >=
      proposal_loan_value * 2
  end

  def validate_main_proponent_monthly_income(%ProposalModel{
        proposal_loan_value: proposal_loan_value,
        proposal_number_of_monthly_installments: proposal_number_of_monthly_installments,
        proponents: proponents
      }) do
    main_proponent = Enum.find(proponents, & &1.proponent_is_main)

    loan_installment_amount = proposal_loan_value / proposal_number_of_monthly_installments

    cond do
      main_proponent.proponent_age >= 18 && main_proponent.proponent_age <= 24 ->
        main_proponent.proponent_monthly_income >= loan_installment_amount * 4

      main_proponent.proponent_age >= 24 && main_proponent.proponent_age <= 50 ->
        main_proponent.proponent_monthly_income >= loan_installment_amount * 3

      main_proponent.proponent_age >= 50 ->
        main_proponent.proponent_monthly_income >= loan_installment_amount * 2
    end
  end
end
