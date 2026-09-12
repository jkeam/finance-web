require 'yaml'
require 'date'

# Load retirement assumptions from db/seeds/custom_data-style import dir
import_dir = ENV.fetch("IMPORT_DIR") { "import" }
retirement_file = Rails.root.join(import_dir, "retirement_assumptions.yaml")

if retirement_file.exist?
  data = YAML.load_file(retirement_file)
  input = data["retirement_assumption"]

  if input
    assumption = RetirementAssumption.current
    assumption.safe_withdrawal_rate = input["safe_withdrawal_rate"] if input.key?("safe_withdrawal_rate")
    assumption.expected_annual_return = input["expected_annual_return"] if input.key?("expected_annual_return")
    assumption.target_retirement_age = input["target_retirement_age"] if input.key?("target_retirement_age")
    assumption.birthdate = Date.parse(input["birthdate"].to_s) if input.key?("birthdate")
    assumption.save!
  end
end
