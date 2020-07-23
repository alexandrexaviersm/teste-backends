Code.require_file("./bcredi_proposal_validator/schemas/proposal_model.ex")

defmodule Validations do
  @moduledoc """
  Validations Public API
  """
  def check_for_valid_proposals(proposal_models) do
    Enum.map(proposal_models, fn proposal_model ->
      with true <- validate_value_of_proposal_loan(proposal_model),
           true <- validate_number_of_monthly_installments(proposal_model),
           true <- validate_minimum_number_of_proponents(proposal_model),
           true <- validate_has_one_main_proponent(proposal_model),
           true <- validate_proponents_age(proposal_model),
           true <- validate_has_at_least_one_warranty(proposal_model),
           true <- validate_warranties_values(proposal_model),
           true <- validate_main_proponent_monthly_income(proposal_model) do
        proposal_model.proposal_id
      else
        _ -> false
      end
    end)
  end

  @doc """
  Loan amount must be between 30_000 and 3_000_000
  """
  def validate_value_of_proposal_loan(%ProposalModel{proposal_loan_value: proposal_loan_value}) do
    proposal_loan_value >= 30_000.0 && proposal_loan_value <= 3_000_000.0
  end

  @doc """
  The monthly installments must be paid between 2 and 15 years
  """
  def validate_number_of_monthly_installments(%ProposalModel{
        proposal_number_of_monthly_installments: proposal_number_of_monthly_installments
      }) do
    proposal_number_of_monthly_installments >= 24 &&
      proposal_number_of_monthly_installments <= 180
  end

  @doc """
  There must be at least 2 proponents per proposal
  """
  def validate_minimum_number_of_proponents(%ProposalModel{proponents: proponents}) do
    length(proponents) >= 2
  end

  @doc """
  There must be exactly 1 main proponent per proposal
  """
  def validate_has_one_main_proponent(%ProposalModel{proponents: proponents}) do
    Enum.filter(proponents, & &1.proponent_is_main)
    |> length()
    |> Kernel.==(1)
  end

  @doc """
  All proponents must be over 18 years old
  """
  def validate_proponents_age(%ProposalModel{proponents: proponents}) do
    Enum.all?(proponents, &(&1.proponent_age >= 18))
  end

  @doc """
  There must be at least 1 warranty per proposal
  """
  def validate_has_at_least_one_warranty(%ProposalModel{warranties: warranties}) do
    length(warranties) >= 2
  end

  @doc """
  The sum of the warranties values must be greater or equal to twice the loan amount
  """
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

  @doc """
  The monthly income of main proponent must be at least:
    - 4 times the loan installment amount, if his age is between 18 and 24 years old
    - 3 times the loan installment amount, if his age is between 24 and 50 years old
    - 2 times the loan installment amount, if his age is over 50 years old
  """
  def validate_main_proponent_monthly_income(%ProposalModel{
        proposal_loan_value: proposal_loan_value,
        proposal_number_of_monthly_installments: proposal_number_of_monthly_installments,
        proponents: proponents
      }) do
    main_proponent = Enum.find(proponents, & &1.proponent_is_main)

    loan_installment_amount = proposal_loan_value / proposal_number_of_monthly_installments

    cond do
      main_proponent.proponent_age >= 18 && main_proponent.proponent_age < 24 ->
        main_proponent.proponent_monthly_income >= loan_installment_amount * 4

      main_proponent.proponent_age >= 24 && main_proponent.proponent_age < 50 ->
        main_proponent.proponent_monthly_income >= loan_installment_amount * 3

      main_proponent.proponent_age >= 50 ->
        main_proponent.proponent_monthly_income >= loan_installment_amount * 2
    end
  end
end
