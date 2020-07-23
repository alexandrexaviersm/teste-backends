Code.require_file("./bcredi_proposal_validator/validations.ex")

ExUnit.start()

defmodule ValidationsTest do
  use ExUnit.Case, async: true

  setup :valid_proposal_model

  describe "Value of a proposal loan" do
    test "should return true for a proposal with a loan amount bigger than 30_000", %{
      valid_proposal_model: proposal_model
    } do
      attrs = %{proposal_model | proposal_loan_value: 50_000}

      assert Validations.validate_value_of_proposal_loan(attrs)
    end

    test "should return true for a proposal with a loan amount less than 3_000_000", %{
      valid_proposal_model: proposal_model
    } do
      attrs = %{proposal_model | proposal_loan_value: 2_000_000}

      assert Validations.validate_value_of_proposal_loan(attrs)
    end

    test "should return false for a proposal with a loan amount less than 30_000", %{
      valid_proposal_model: proposal_model
    } do
      attrs = %{proposal_model | proposal_loan_value: 20_000}

      refute Validations.validate_value_of_proposal_loan(attrs)
    end

    test "should return false for a proposal with a loan amount bigger than 3_000_000", %{
      valid_proposal_model: proposal_model
    } do
      attrs = %{proposal_model | proposal_loan_value: 5_000_000}

      refute Validations.validate_value_of_proposal_loan(attrs)
    end
  end

  describe "Monthly installments" do
    test "should return true for a monthly installments that will be paid between 2 and 15 years",
         %{
           valid_proposal_model: proposal_model
         } do
      attrs = %{proposal_model | proposal_number_of_monthly_installments: 32}

      assert Validations.validate_number_of_monthly_installments(attrs)
    end

    test "should return false for a monthly installments that will be paid less than 2 years",
         %{
           valid_proposal_model: proposal_model
         } do
      attrs = %{proposal_model | proposal_number_of_monthly_installments: 20}

      refute Validations.validate_number_of_monthly_installments(attrs)
    end
  end

  test "should return false for a monthly installments that will be paid for more than 15 years",
       %{
         valid_proposal_model: proposal_model
       } do
    attrs = %{proposal_model | proposal_number_of_monthly_installments: 200}

    refute Validations.validate_number_of_monthly_installments(attrs)
  end

  describe "Proponents per proposal" do
    test "should return true if there are 2 proponents per proposal",
         %{
           valid_proposal_model: proposal_model
         } do
      assert Validations.validate_minimum_number_of_proponents(proposal_model)
    end

    test "should return false if there are less than 2 proponents per proposal",
         %{
           valid_proposal_model: proposal_model
         } do
      attrs = %{
        proposal_model
        | proponents: [
            %{
              proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
              proponent_age: 55,
              proponent_monthly_income: 365_997.74,
              proponent_is_main: true
            }
          ]
      }

      refute Validations.validate_minimum_number_of_proponents(attrs)
    end
  end

  describe "Main proponent per proposal" do
    test "should return true if there are exacly one main proponent per proposal",
         %{
           valid_proposal_model: proposal_model
         } do
      assert Validations.validate_has_one_main_proponent(proposal_model)
    end

    test "should return false if there are more than one main proponent per proposal",
         %{
           valid_proposal_model: proposal_model
         } do
      attrs = %{
        proposal_model
        | proponents: [
            %{
              proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
              proponent_age: 55,
              proponent_monthly_income: 365_997.74,
              proponent_is_main: true
            },
            %{
              proponent_id: "a1c5ca74-e7e7-4f1e-9ee9-2f03ee1c4612",
              proponent_age: 51,
              proponent_monthly_income: 192_567.32,
              proponent_is_main: true
            }
          ]
      }

      refute Validations.validate_has_one_main_proponent(attrs)
    end
  end

  describe "Proponents age" do
    test "should return true if All proponents are over 18 years old",
         %{
           valid_proposal_model: proposal_model
         } do
      assert Validations.validate_proponents_age(proposal_model)
    end

    test "should return false if there are any proponent less than 18 years old",
         %{
           valid_proposal_model: proposal_model
         } do
      attrs = %{
        proposal_model
        | proponents: [
            %{
              proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
              proponent_age: 55,
              proponent_monthly_income: 365_997.74,
              proponent_is_main: true
            },
            %{
              proponent_id: "a1c5ca74-e7e7-4f1e-9ee9-2f03ee1c4612",
              proponent_age: 16,
              proponent_monthly_income: 192_567.32,
              proponent_is_main: true
            }
          ]
      }

      refute Validations.validate_proponents_age(attrs)
    end
  end

  describe "Warranties per proposal" do
    test "should return true if there is at least one warranty",
         %{
           valid_proposal_model: proposal_model
         } do
      assert Validations.validate_has_at_least_one_warranty(proposal_model)
    end

    test "should return false if there are no one warranty",
         %{
           valid_proposal_model: proposal_model
         } do
      attrs = %{
        proposal_model
        | warranties: []
      }

      refute Validations.validate_has_at_least_one_warranty(attrs)
    end
  end

  describe "Values of warranties values bigger than loan amount" do
    test "should return true if sum of the warranties values are greater to twice the loan amount",
         %{
           valid_proposal_model: proposal_model
         } do
      assert Validations.validate_warranties_values(proposal_model)
    end

    test "should return false if sum of the warranties values aren't greater to twice the loan amount",
         %{
           valid_proposal_model: proposal_model
         } do
      attrs = %{
        proposal_model
        | warranties: [
            %{
              warranty_id: "2aa5f044-552f-444b-b213-eb3892bdc140",
              warranty_value: 500_000,
              warranty_province: "GO"
            }
          ]
      }

      refute Validations.validate_warranties_values(attrs)
    end
  end

  describe "Property Warranties of the states PR, SC and RS aren't accepted" do
    test "should return true if there are no warranty from PR, SC or RS",
         %{
           valid_proposal_model: proposal_model
         } do
      assert Validations.validate_state_of_warranties(proposal_model)
    end

    test "should return false if warranty is from PR, SC or RS",
         %{
           valid_proposal_model: proposal_model
         } do
      for state <- ~w(PR SC RS) do
        attrs = %{
          proposal_model
          | warranties: [
              %{
                warranty_id: "2aa5f044-552f-444b-b213-eb3892bdc140",
                warranty_value: 6_955_365.82,
                warranty_province: state
              }
            ]
        }

        refute Validations.validate_state_of_warranties(attrs)
      end
    end
  end

  describe "Monthly income of main proponent" do
    test "should return true if monthly income of main proponent is 4 times the loan installment" do
      attrs = %ProposalModel{
        proposal_loan_value: 100.0,
        proposal_number_of_monthly_installments: 1,
        proponents: [
          %{
            proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
            proponent_age: 20,
            proponent_monthly_income: 500.0,
            proponent_is_main: true
          }
        ]
      }

      assert Validations.validate_main_proponent_monthly_income(attrs)
    end

    test "should return true if monthly income of main proponent is 3 times the loan installment" do
      attrs = %ProposalModel{
        proposal_loan_value: 200.0,
        proposal_number_of_monthly_installments: 1,
        proponents: [
          %{
            proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
            proponent_age: 30,
            proponent_monthly_income: 600.0,
            proponent_is_main: true
          }
        ]
      }

      assert Validations.validate_main_proponent_monthly_income(attrs)
    end

    test "should return true if monthly income of main proponent is 2 times the loan installment" do
      attrs = %ProposalModel{
        proposal_loan_value: 100.0,
        proposal_number_of_monthly_installments: 1,
        proponents: [
          %{
            proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
            proponent_age: 55,
            proponent_monthly_income: 250.0,
            proponent_is_main: true
          }
        ]
      }

      assert Validations.validate_main_proponent_monthly_income(attrs)
    end

    test "should return false if monthly income of main proponent isn't 4 times the loan installment" do
      attrs = %ProposalModel{
        proposal_loan_value: 100.0,
        proposal_number_of_monthly_installments: 1,
        proponents: [
          %{
            proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
            proponent_age: 20,
            proponent_monthly_income: 300.0,
            proponent_is_main: true
          }
        ]
      }

      refute Validations.validate_main_proponent_monthly_income(attrs)
    end

    test "should return false if monthly income of main proponent isn't 3 times the loan installment" do
      attrs = %ProposalModel{
        proposal_loan_value: 200.0,
        proposal_number_of_monthly_installments: 1,
        proponents: [
          %{
            proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
            proponent_age: 30,
            proponent_monthly_income: 500.0,
            proponent_is_main: true
          }
        ]
      }

      refute Validations.validate_main_proponent_monthly_income(attrs)
    end

    test "should return false if monthly income of main proponent isn't 2 times the loan installment" do
      attrs = %ProposalModel{
        proposal_loan_value: 200.0,
        proposal_number_of_monthly_installments: 2,
        proponents: [
          %{
            proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
            proponent_age: 55,
            proponent_monthly_income: 150.0,
            proponent_is_main: true
          }
        ]
      }

      refute Validations.validate_main_proponent_monthly_income(attrs)
    end
  end

  def valid_proposal_model(_context) do
    [
      valid_proposal_model: %ProposalModel{
        proposal_id: "52f0b3f2-f838-4ce2-96ee-9876dd2c0cf6",
        proposal_loan_value: 2_689_584.0,
        proposal_number_of_monthly_installments: 72,
        proponents: [
          %{
            proponent_id: "ba343064-6f41-419d-a455-8cbdcbc807b1",
            proponent_age: 55,
            proponent_monthly_income: 365_997.74,
            proponent_is_main: true
          },
          %{
            proponent_id: "a1c5ca74-e7e7-4f1e-9ee9-2f03ee1c4612",
            proponent_age: 51,
            proponent_monthly_income: 192_567.32,
            proponent_is_main: false
          }
        ],
        warranties: [
          %{
            warranty_id: "2aa5f044-552f-444b-b213-eb3892bdc140",
            warranty_value: 6_955_365.82,
            warranty_province: "GO"
          },
          %{
            warranty_id: "2a6eba4f-5109-41fd-b977-87b1156d7a05",
            warranty_value: 6_718_669.33,
            warranty_province: "ES"
          }
        ]
      }
    ]
  end
end
