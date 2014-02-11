module Qb
  attr_accessor :new, :exs, :cust, :sr, :prod, :acc

  extend self

  def init
    set_sr
    set_c
    set_p
    set_a
    create_new_order
    set_order_details
  end

  def set_sr
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @sr = Quickbooks::Service::SalesReceipt.new
    @sr.access_token = oauth_client
    @sr.company_id = ENV['QB_RID']
    @exs = @sr.query("select * from SalesReceipt where DocNumber = 'TEST4'").entries[0]
  end

  def set_c
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @cust = Quickbooks::Service::Customer.new
    @cust.access_token = oauth_client
    @cust.company_id = ENV['QB_RID']
  end

  def set_p
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @prod = Quickbooks::Service::Item.new
    @prod.access_token = oauth_client
    @prod.company_id = ENV['QB_RID']
  end

  def set_a
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @acc = Quickbooks::Service::Account.new
    @acc.access_token = oauth_client
    @acc.company_id = ENV['QB_RID']
  end

  def create_new_order
    @new = Quickbooks::Model::SalesReceipt.new
  end

  def set_order_details
    @new.placed_on = Time.new(2014,5,30)
    @new.doc_number = 'TEST4'
    customer_ref = Quickbooks::Model::BaseReference.new(@cust.query("select * from Customer where DisplayName = 'Web Orders'").entries[0].id)
    customer_ref.name = 'Web Orders'
    @new.customer_ref = customer_ref
    @new.line_items = []
    bill_email = Quickbooks::Model::EmailAddress.new
    bill_email.address = 'test@test.com'
    @new.bill_email = bill_email
    bill_address = Quickbooks::Model::PhysicalAddress.new
    bill_address.line1 = 'John Bill Smith'
    bill_address.line2 = '123 Main Lane'
    bill_address.city = 'Big City'
    bill_address.country = 'USA'
    bill_address.postal_code = '12345'
    @new.bill_address = bill_address
    ship_address = Quickbooks::Model::PhysicalAddress.new
    ship_address.line1 = 'John Ship Smith'
    ship_address.line2 = '123 Ship Lane'
    ship_address.city = 'Big City'
    ship_address.country = 'USA'
    ship_address.postal_code = '07035'
    @new.ship_address = ship_address
    deposit_account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = 'Bank of America'").entries[0].id)
    deposit_account_ref.name = 'Bank of America'
    @new.deposit_to_account_ref = deposit_account_ref
  end

  def add_line_item(sku,price,q)
    line_item = Quickbooks::Model::Line.new
    line_item.detail_type = 'SalesItemLineDetail'
    line_item.sales_item_line_detail = Quickbooks::Model::SalesItemLineDetail.new
    item_ref = Quickbooks::Model::BaseReference.new(@prod.query("select * from Item where Name = '#{sku}'").entries[0].id)
    item_ref.name = sku
    line_item.sales_item_line_detail.item_ref = item_ref
    line_item.sales_item_line_detail.unit_price = BigDecimal.new(price.to_s)
    line_item.sales_item_line_detail.quantity = BigDecimal.new(q.to_s)
    line_item.amount = BigDecimal.new((price*q).to_s)
    line_item
  end

  def save_order
    @sr.create(@new)
  end



end
