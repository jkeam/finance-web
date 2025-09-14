require 'csv'
require 'date'
require 'yaml'

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
def create_transaction(file_path, account)
  CSV.foreach(file_path, headers: true) do |row|
    amount = row['amount']
    positive = true
    if amount.include?('-')
      positive = false
    end
    category = row['category'].downcase.gsub(' ', '_').strip

    # commercial banks track the normal way,
    # but I want the negative to match my credit cards
    # where spending is positive amounts
    if account.commercial?
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
        account: account
      )
    rescue => e
      STDERR.puts "Error for #{file_path}, error is #{e.message}"
    end
  end
end

Transaction.destroy_all
Account.destroy_all
Bank.destroy_all

# Prepare lookup data
banks = YAML.load_file(Rails.root.join('import/banks.yaml'))

# Build banks and accounts
name_to_bank = {}
bank_name_to_accounts = {}
banks['banks'].each do |bank_input|
  bank_name = bank_input['name']
  bank = Bank.find_or_create_by!(name: bank_name)
  name_to_bank[bank_name] = bank

  accounts = []
  bank_name_to_accounts[bank_name] = accounts
  bank_input['accounts'].each do |account_input|
    accounts << Account.find_or_create_by!(
      name: account_input['name'],
      bank: bank,
      category: account_input['type'].to_s
    )
  end
end

# Process each file
csv_files.each do |file_path|
  matched_bank = false
  matched_account = false
  filename = file_path.downcase
  name_to_bank.each do |name, bank|
    if filename.include?(name.downcase)
      matched_bank = true
      accounts = bank_name_to_accounts[bank.name]
      if accounts.size == 0
        puts "No accounts found for bank #{bank.name}"
        break
      elsif accounts.size == 1
        matched_account = true
        create_transaction(file_path, accounts[0])
        break
      else
        accounts.each do |cur_account|
          if filename.include?(cur_account.name.downcase)
            matched_account = true
            create_transaction(file_path, cur_account)
            break
          end
        end
      end
      break
    end
  end
  # debug information
  # puts "filename: #{filename}"
  # puts "matched_bank: #{matched_bank}"
  # puts "matched_account: #{matched_account}"
end
