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

desc 'Seed db with Orders'
task 'db:seed_orders' => :environment do
  CSV.foreach('seed-data/full-upload.csv', :headers=>true) do |row|
    if row[22] == nil
      order = Order.find_by(order_number: row[2])
      if order == nil
        p "*"*100
        puts "Creating a New Order for #{row[2]}"
        order = Order.create(order_number: row[2])
        order.sub = Sub.find_by(cid: row[0].to_i)
        order.created_at = Date.strptime(row[3], '%m/%d/%y')
        order.plan = row[4]
        order.name = row[5]
        order.email = row[6]
        order.address = row[7]
        order.address2 = row[8]
        order.city = row[9]
        order.state = row[10]
        order.zip = row[11]
        order.country = row[12]
        order.billing_name = row[14]
        order.billing_address = row[15]
        order.billing_address2 = row[16]
        order.billing_city = row[17]
        order.billing_state = row[18]
        order.billing_zip = row[19]
        order.billing_country = row[20]
        order.trans_id = row[1].to_i
        order.save
      end
      product = Product.find_or_create_by(sku: row[13].downcase)
      if !order.products.include?(product)
        puts "Adding sku #{row[13].downcase} to order"
        order.products << product
      end

    end

  end
end

desc 'Sync Shopify Inventory with Shopify'
task 'sync_inv' => :environment do
  Product.sync_to_shopify
end

desc 'Refresh Upfront Subs'
task 'refresh_upfronts' => :environment do
  UpfrontSub.refresh
end

desc 'Refresh Current Subscriber Info'
task 'refresh_subs' => :environment do
    DataSession.destroy_all
    DataSession.create(data: Sub.due)
end


