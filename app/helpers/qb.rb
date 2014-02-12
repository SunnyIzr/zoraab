module Qb

  extend self

  def init
    sales_receipt_service
    customer_service
    product_service
    acct_service
    payment_method_service
  end

  def create_order(order)
    p '*'*100
    p "Creating Order " + order[:number]
    if @sr.query("select * from SalesReceipt where DocNumber = '"+"#{order[:number]}"+"'").entries.size == 0
      qbo = new_order(order)
      save_order(qbo)
    else
      p 'Order already exists'
      p '*'*100
    end
  end


  def new_order(order)
    qb_order = Quickbooks::Model::SalesReceipt.new
    qb_order.placed_on = order[:created_at]
    qb_order.doc_number = order[:number]
    customer_ref = Quickbooks::Model::BaseReference.new(@cust.query("select * from Customer where DisplayName = 'Web Orders'").entries[0].id)
    customer_ref.name = 'Web Orders'
    qb_order.customer_ref = customer_ref
    bill_email = Quickbooks::Model::EmailAddress.new
    bill_email.address = order[:email]
    qb_order.bill_email = bill_email
    payment_method_ref = Quickbooks::Model::BaseReference.new(@pmt.query("select * from PaymentMethod where Name = '"+"#{order[:gateway]}"+"'").entries[0].id)
    payment_method_ref.name = order[:gateway]
    qb_order.payment_method_ref = payment_method_ref
    bill_address = Quickbooks::Model::PhysicalAddress.new
    bill_address.line1 = order[:billing_address][:name]
    bill_address.line2 = order[:billing_address][:address1]
    bill_address.city = order[:billing_address][:city]
    bill_address.country_sub_division_code = order[:billing_address][:state]
    bill_address.country = order[:billing_address][:country]
    bill_address.postal_code = order[:billing_address][:zip]
    qb_order.bill_address = bill_address
    ship_address = Quickbooks::Model::PhysicalAddress.new
    ship_address.line1 = order[:shipping_address][:name]
    ship_address.line2 = order[:shipping_address][:address1]
    ship_address.city = order[:shipping_address][:city]
    ship_address.country_sub_division_code = order[:shipping_address][:state]
    ship_address.country = order[:shipping_address][:country]
    ship_address.postal_code = order[:shipping_address][:zip]
    qb_order.ship_address = ship_address
    qb_order.deposit_to_account_ref = deposit_to(order)
    qb_order.line_items = create_line_items(order[:line_items], order[:discount],order[:shipping_total])
    qb_order
  end

  def create_line_items(line_items, discount, shipping)
    items = line_items.map { |line| add_line_item(line) }
    if discount.to_f > 0.0
      items << add_discount_line(discount)
    end
    if shipping.to_f > 0.0
      items << add_shipping_line(shipping)
    end
    return items
  end

  def deposit_to(order)
    if order[:gateway] == 'paypal'
      deposit_account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = 'Paypal AR'").entries[0].id)
      deposit_account_ref.name = 'Paypal AR'
      return deposit_account_ref
    else
      deposit_account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = 'Bank of America'").entries[0].id)
      deposit_account_ref.name = 'Bank of America'
      return deposit_account_ref
    end
  end

  def add_line_item(line)
    p "Adding Item #{line[:sku]}"
    line_item = Quickbooks::Model::Line.new
    line_item.detail_type = 'SalesItemLineDetail'
    line_item.sales_item_line_detail = Quickbooks::Model::SalesItemLineDetail.new
    item_ref = Quickbooks::Model::BaseReference.new(@prod.query("select * from Item where Name = '#{line[:sku]}'").entries[0].id)
    item_ref.name = line[:sku]
    line_item.sales_item_line_detail.item_ref = item_ref
    line_item.sales_item_line_detail.unit_price = BigDecimal.new(line[:price])
    line_item.sales_item_line_detail.quantity = BigDecimal.new(line[:q])
    line_item.amount = BigDecimal.new((line[:price].to_f*line[:q].to_f).to_s)
    line_item
  end

  def add_discount_line(discount)
    line_item = Quickbooks::Model::Line.new
    line_item.detail_type = 'SalesItemLineDetail'
    line_item.sales_item_line_detail = Quickbooks::Model::SalesItemLineDetail.new
    item_ref = Quickbooks::Model::BaseReference.new(@prod.query("select * from Item where Name = 'Discount Code'").entries[0].id)
    item_ref.name = 'Discount Code'
    line_item.sales_item_line_detail.item_ref = item_ref
    line_item.sales_item_line_detail.unit_price = BigDecimal.new('-'+discount)
    line_item.sales_item_line_detail.quantity = BigDecimal.new(1)
    line_item.amount = BigDecimal.new('-'+discount)
    line_item
  end

  def add_shipping_line(shipping)
    line_item = Quickbooks::Model::Line.new
    line_item.detail_type = 'SalesItemLineDetail'
    line_item.sales_item_line_detail = Quickbooks::Model::SalesItemLineDetail.new
    item_ref = Quickbooks::Model::BaseReference.new(@prod.query("select * from Item where Name = 'Shipping Charge'").entries[0].id)
    item_ref.name = 'Shipping_Charge'
    line_item.sales_item_line_detail.item_ref = item_ref
    line_item.sales_item_line_detail.unit_price = BigDecimal.new(shipping)
    line_item.sales_item_line_detail.quantity = BigDecimal.new(1)
    line_item.amount = BigDecimal.new(shipping)
    line_item
  end

  def save_order(qb_order)
    p "Saving Order"
    @sr.create(qb_order)
    p "Saved"
    p "*"*100
  end

  private
  def sales_receipt_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @sr = Quickbooks::Service::SalesReceipt.new
    @sr.access_token = oauth_client
    @sr.company_id = ENV['QB_RID']
  end

  def payment_method_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @pmt = Quickbooks::Service::PaymentMethod.new
    @pmt.access_token = oauth_client
    @pmt.company_id = ENV['QB_RID']
  end

  def customer_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @cust = Quickbooks::Service::Customer.new
    @cust.access_token = oauth_client
    @cust.company_id = ENV['QB_RID']
  end

  def product_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @prod = Quickbooks::Service::Item.new
    @prod.access_token = oauth_client
    @prod.company_id = ENV['QB_RID']
  end

  def acct_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
    @acc = Quickbooks::Service::Account.new
    @acc.access_token = oauth_client
    @acc.company_id = ENV['QB_RID']
  end


end
