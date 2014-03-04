module Qb
  attr_reader :sr, :prod, :po, :ven, :exp, :acc

  extend self

  def init
    sales_receipt_service
    customer_service
    product_service
    acct_service
    payment_method_service
  end

  def product_exist?(sku)
    product_service
    return @prod.query("select * from Item where name = '"+sku+"'").entries.size > 0
  end

  def products_dont_exist?(ary_of_skus)
    product_service
    ary_of_skus.select do |sku|
      !product_exist?(sku)
    end
  end

  def get_order(order_number)
    return @sr.query("select * from SalesReceipt where DocNumber = '"+order_number+"'").entries.first
  end

  def create_order(order)
    init
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
    qb_order.customer_ref = customer_ref(order)
    bill_email = Quickbooks::Model::EmailAddress.new
    bill_email.address = order[:email]
    qb_order.bill_email = bill_email
    payment_method_ref = Quickbooks::Model::BaseReference.new(@pmt.query("select * from PaymentMethod where Name = '"+"#{order[:gateway]}"+"'").entries[0].id)
    payment_method_ref.name = order[:gateway]
    qb_order.payment_method_ref = payment_method_ref
    qb_order.private_note = order[:memo]
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
    qb_order.line_items = create_line_items(order)
    qb_order
  end

  def customer_ref(order)
    if order[:type] == 'Shopify'
      customer_ref = Quickbooks::Model::BaseReference.new(@cust.query("select * from Customer where DisplayName = 'Web Orders'").entries[0].id)
      customer_ref.name = 'Web Orders'
      return customer_ref
    elsif order[:type] == 'Subscription'
      customer_ref = Quickbooks::Model::BaseReference.new(@cust.query("select * from Customer where DisplayName = 'Subscriptions'").entries[0].id)
      customer_ref.name = 'Subscriptions'
      return customer_ref
    elsif order[:type] == 'Amazon'
      customer_ref = Quickbooks::Model::BaseReference.new(@cust.query("select * from Customer where DisplayName = 'Amazon Orders'").entries[0].id)
      customer_ref.name = 'Amazon Orders'
      return customer_ref
    end
  end

  def create_line_items(order)
    items = order[:line_items].map do |line|
      if item_exist?(line[:sku])
        add_line_item(line)
      else
        p '-'*20 + line[:sku] + ' does not exist!' + '-'*20
        nil
      end
    end
    items.compact!
    items << add_fee_line(order) if !order[:fees].nil?
    items << add_gift_card_line(order) if !order[:gift_card_redemption].nil?

    if order[:discount].to_f > 0.0
      items << add_discount_line(order[:discount])
    end
    if order[:shipping_total].to_f > 0.0
      items << add_shipping_line(order[:shipping_total])
    end
    return items
  end

  def deposit_to(order)
    if order[:gateway] == 'paypal'
      deposit_account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = 'Paypal'").entries[0].id)
      deposit_account_ref.name = 'Paypal'
      return deposit_account_ref
    elsif order[:gateway] == 'braintree'
      deposit_account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = 'Braintree AR'").entries[0].id)
      deposit_account_ref.name = 'Braintree AR'
      return deposit_account_ref
    elsif order[:gateway] == 'amazon'
      deposit_account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = 'Amazon'").entries[0].id)
      deposit_account_ref.name = 'Amazon'
      return deposit_account_ref
    else
      deposit_account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = 'Shopify Payments AR'").entries[0].id)
      deposit_account_ref.name = 'Shopify Payments AR'
      return deposit_account_ref
    end
  end

  def add_fee_line(order)
    line_item = Quickbooks::Model::Line.new
    line_item.detail_type = 'SalesItemLineDetail'
    line_item.sales_item_line_detail = Quickbooks::Model::SalesItemLineDetail.new
    item_ref = Quickbooks::Model::BaseReference.new(@prod.query("select * from Item where Name = '"+order[:fees].keys.first+"'").entries[0].id)
    item_ref.name = order[:fees].keys.first
    line_item.sales_item_line_detail.item_ref = item_ref
    line_item.sales_item_line_detail.unit_price = BigDecimal.new('-'+order[:fees].values.first)
    line_item.sales_item_line_detail.quantity = BigDecimal.new(1)
    line_item.amount = BigDecimal.new('-'+order[:fees].values.first.to_s)
    line_item
  end

  def add_gift_card_line(order)
    line_item = Quickbooks::Model::Line.new
    line_item.detail_type = 'SalesItemLineDetail'
    line_item.sales_item_line_detail = Quickbooks::Model::SalesItemLineDetail.new
    item_ref = Quickbooks::Model::BaseReference.new(@prod.query("select * from Item where Name = 'Gift Card'").entries[0].id)
    item_ref.name = 'Gift Card'
    line_item.sales_item_line_detail.item_ref = item_ref
    line_item.sales_item_line_detail.unit_price = BigDecimal.new('-'+order[:gift_card_redemption].to_s)
    line_item.sales_item_line_detail.quantity = BigDecimal.new(1)
    line_item.amount = BigDecimal.new('-'+order[:gift_card_redemption].to_s)
    line_item
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

  def item_exist?(sku)
    @prod.query("select * from Item where Name = '"+sku+"'").entries.size != 0
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

  def delete_order(order_number)
    qbo = get_order(order_number)
    @sr.delete_by_query_string(qbo)
  end

  def get_po(po_number)
    po_service
    return @po.query("select * from PurchaseOrder where DocNumber = '"+po_number+"'").entries.first
  end

  def create_po(inv)
    po_service
    ven_service
    product_service
    qb_po = new_po(inv)
    @po.create(qb_po)
  end

  def new_po(inv)
    qb_po = Quickbooks::Model::PurchaseOrder.new
    qb_po.txn_date = inv[:created_at]
    qb_po.due_date = inv[:created_at]
    qb_po.doc_number = inv[:number]
    qb_po.po_status = 'Open'
    v_ref = Quickbooks::Model::BaseReference.new(@ven.query("select * from Vendor where DisplayName = '"+"#{inv[:vendor]}"+"'").entries[0].id)
    v_ref.name = inv[:vendor]
    qb_po.vendor_ref = v_ref
    qb_po.total_amount = BigDecimal.new(inv[:total])
    qb_po.line_items = []
    inv[:line_items].each { |line| qb_po.line_items << add_po_line_item(line)}
    qb_po
  end

  def add_po_line_item(line)
    p "Adding Item #{line[:sku]}"
    line_item = Quickbooks::Model::PurchaseLineItem.new
    line_item.amount = BigDecimal.new((line[:price].to_f*line[:q].to_f).to_s)
    line_item.detail_type = "ItemBasedExpenseLineDetail"
    line_item.item_based_expense_line_detail = Quickbooks::Model::ItemBasedExpenseLineDetail.new
    item_ref = Quickbooks::Model::BaseReference.new(@prod.query("select * from Item where Name = '#{line[:sku]}'").entries[0].id)
    item_ref.name = line[:sku]
    line_item.item_based_expense_line_detail.item_ref = item_ref
    line_item.item_based_expense_line_detail.quantity = BigDecimal.new(line[:q].to_s)
    line_item.item_based_expense_line_detail.unit_price = BigDecimal.new(line[:price].to_s)
    line_item
  end

  # example: {:vendor=>"Google Adwords", :amount=>500.0, :pmt_acct=>"Google Adwords", :date=>2013-12-31 00:00:00 -0500, :exp_acct=>"Online Advertising"}

  def create_exp(exp)
    exp_service
    ven_service
    acct_service
    qb_exp = new_exp(exp)
    @exp.create(qb_exp)
  end

  def new_exp(exp)
    qb_exp = Quickbooks::Model::Purchase.new
    qb_exp.txn_date = exp[:date]
    qb_exp.account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = '"+exp[:pmt_acct]+"'").entries[0].id)
    qb_exp.total_amount = BigDecimal.new(exp[:amount].to_s)
    qb_exp.payment_type = 'CreditCard'
    entity_ref = Quickbooks::Model::BaseReference.new(@ven.query("select * from Vendor where DisplayName = '"+"#{exp[:vendor]}"+"'").entries[0].id)
    entity_ref.name = exp[:vendor]
    qb_exp.entity_ref = entity_ref
    line = Quickbooks::Model::PurchaseLineItem.new
    line.amount = BigDecimal.new(exp[:amount].to_s)
    line.detail_type = "AccountBasedExpenseLineDetail"
    line.account_based_expense_line_detail = Quickbooks::Model::AccountBasedExpenseLineDetail.new
    line.account_based_expense_line_detail.account_ref = Quickbooks::Model::BaseReference.new(@acc.query("select * from Account where Name = '"+exp[:exp_acct]+"'").entries[0].id)
    line.account_based_expense_line_detail.account_ref.name = exp[:exp_acct]
    qb_exp.line_items = [line]

    return qb_exp
  end

  private
  def oauth_client
    OAuth::AccessToken.new($qb_oauth_consumer, ENV['QB_TOKEN'] , ENV['QB_TOKEN_SECRET'])
  end

  def sales_receipt_service
    @sr = Quickbooks::Service::SalesReceipt.new
    @sr.access_token = oauth_client
    @sr.company_id = ENV['QB_RID']
  end

  def payment_method_service
    @pmt = Quickbooks::Service::PaymentMethod.new
    @pmt.access_token = oauth_client
    @pmt.company_id = ENV['QB_RID']
  end

  def customer_service
    @cust = Quickbooks::Service::Customer.new
    @cust.access_token = oauth_client
    @cust.company_id = ENV['QB_RID']
  end

  def product_service
    @prod = Quickbooks::Service::Item.new
    @prod.access_token = oauth_client
    @prod.company_id = ENV['QB_RID']
  end

  def acct_service
    @acc = Quickbooks::Service::Account.new
    @acc.access_token = oauth_client
    @acc.company_id = ENV['QB_RID']
  end

  def po_service
    @po = Quickbooks::Service::PurchaseOrder.new
    @po.access_token = oauth_client
    @po.company_id = ENV['QB_RID']
  end

  def ven_service
    @ven = Quickbooks::Service::Vendor.new
    @ven.access_token = oauth_client
    @ven.company_id = ENV['QB_RID']
  end

  def exp_service
    @exp = Quickbooks::Service::Purchase.new
    @exp.access_token = oauth_client
    @exp.company_id = ENV['QB_RID']
  end


end
