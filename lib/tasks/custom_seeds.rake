namespace :db do
  namespace :seed do
    desc "Custom load seed data from db/seeds/custom_data"
      task custom: :environment do
        seed_files = Dir[Rails.root.join("db", "seeds", "custom_data", "*.rb")]
        seed_files.each do |file|
          puts "Loading custom seed file: #{File.basename(file)}"
          load(file)
        end
      end
  end
end
