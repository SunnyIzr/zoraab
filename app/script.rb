
missing = []
s.each_with_index do |cid,i|
puts "Completing #{i+1} of #{s.size}"
cid
sub = Chargify::Subscription.find(cid)
zsub = Sub.find_by(cid: cid)
transactions = sub.transactions
sept_tran = transactions.select{|trans| trans.created_at.month == 9 && trans.transaction_type == 'payment'}[0] 
oct_tran = transactions.select{|trans| trans.created_at.month == 10 && trans.transaction_type == 'payment'}[0]
sept_order = zsub.sub_orders.select{|order| order.created_at.month == 9}[0]
oct_order = zsub.sub_orders.select{|order| order.created_at.month == 10}[0]

if sept_order.nil?
  missing << cid
else
sept_order.trans_id = nil
sept_order.save

unless oct_tran.nil?
oct_order.trans_id = nil
oct_order.save
end

sept_order.trans_id = sept_tran.id
sept_order.save
sept_order.gateway_id = sept_order.braintree_id
sept_order.save

unless oct_tran.nil?
oct_order.trans_id = oct_tran.id
oct_order.save
oct_order.gateway_id = oct_order.braintree_id
oct_order.save
end
end
end