File.foreach(Rails.root.join('import/banks.txt')) do |bank|
  Bank.find_or_create_by!(name: bank)
end
