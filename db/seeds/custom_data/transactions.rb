require 'csv'
require 'date'

# Read in transactions
csv_files = Dir.glob(Rails.root.join('import/*.csv')).map(&:strip)

# Test reading of files (looking for non-utf8)
csv_files.each do |file_path|
  begin
    CSV.read(file_path, headers: true)
  rescue => e
    STDERR.puts "Failed #{file_path} error is #{e.message}"
  end
end

# Insert everything
def create_transaction(flip_bank, file_path, bank)
  CSV.foreach(file_path, headers: true) do |row|
    amount = row['amount']
    positive = true
    if amount.include?('-')
      positive = false
    end
    category = row['category'].downcase.gsub(' ', '_').strip

    # banks track the normal way,
    # but I want the negative to match my credit cards
    # where spending is positive amounts
    if flip_bank
      if positive
        amount = "-#{amount}"
      else
        amount = amount.gsub('-', '')
      end
      positive = !positive
    end

    begin
      Transaction.create!(
        transaction_date: Date.strptime(row['transaction_date'], "%m/%d/%Y"),
        clearing_date: Date.strptime(row['clearing_date'], "%m/%d/%Y"),
        description: row['desc'],
        merchant: row['merchant'],
        category: "category_#{category}",
        transaction_type: "type_#{row['transaction_type'].downcase}",
        purchased_by: row['purchased_by'],
        notes: '',
        amount: Monetize.parse(amount),
        positive: positive,
        bank: bank
      )
    rescue => e
      STDERR.puts "Error for #{file_path}, error is #{e.message}"
    end
  end
end

Transaction.destroy_all
Bank.destroy_all

# Prepare lookup data
name_to_bank = File.readlines(Rails.root.join('import/banks.txt')).map(&:strip).to_h do |bank_name|
  [bank_name, Bank.find_or_create_by!(name: bank_name)]
end
flip_banks = File.readlines(Rails.root.join('import/flip.txt')).map(&:strip).map(&:downcase)

# Process each file
csv_files.each do |file_path|
  name_to_bank.each do |name, bank|
    if file_path.downcase.include?(name.downcase)
      create_transaction(flip_banks.include?(name.downcase), file_path, bank)
      break
    end
  end
end
