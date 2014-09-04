class BraintreeRec < ActiveRecord::Base
  serialize :braintree_transactions, Array
  serialize :grouped_transactions, Array
  
  def import_csv(file)
    CSV.foreach(file, headers: true) do |row|
      self.braintree_transactions << {trans_id: row[0], disb_date: Date.strptime(row[8],'%m/%d/%y'), amt: row[12].to_f }
    end
    self.save
  end
  
  def group_transactions
    dates = self.braintree_transactions.map { |trans| trans[:disb_date] }.uniq
    dates.each do |date|
      orders = []
      trans = self.braintree_transactions.select { |transaction| transaction[:disb_date] == date }
      trans.each do |tran|
        hash = {}
        hash[:trans_id] = tran[:trans_id]
        hash[:amt] = tran[:amt]
        hash[:net_amt] = calc_net_amt(tran[:amt])
        orders << hash
      end
      self.grouped_transactions << {disb_date: date, recd: false, orders: orders}
    end
    self.save
  end
  
  def calc_net_amt(amt)
    fee = (amt * 0.029) + 0.30
    amt -= fee
    amt.round(2)
  end
end