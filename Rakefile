# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Zoraab::Application.load_tasks

desc 'Seed db with Subscribers'
task 'db:seed_subs' => :environment do
  CSV.foreach('seed-data/subs.csv', :headers=>true) do |row|
    p "*"*100
    puts "Adding Subscriber #{row[0]}"
    sub = Sub.create(cid: row[0].to_i)
    puts "retrieving prefs"
    sub.retrieve_wufoo_prefs
    puts "Successfully retrieved prefs:"
    sub.prefs.each do |pref|
      puts pref.pref
    end
  end
end
task 'db:seed_subs_no_wufoo' => :environment do
  CSV.foreach('seed-data/subs-nowufoo.csv', :headers=>true) do |row|
    p "*"*100
    puts "Adding Subscriber #{row[0]}"
    sub = Sub.create(cid: row[0].to_i)
    puts "retrieving prefs"
    abbrs = {'B' => Pref.find_by(pref:'dress'), 'F' => Pref.find_by(pref:'fashion'), 'W' => Pref.find_by(pref: 'fun'), 'C' => Pref.find_by(pref: 'casual')}
    row[1].split('').each do |ltr|
      sub.prefs << abbrs[ltr]
    end
    sub.save
    puts "Successfully retrieved prefs:"
    sub.prefs.each do |pref|
      puts pref.pref
    end
  end
end


