class BraintreeRec < ActiveRecord::Base
  serialize :braintree_transactions, Array
  serialize :grouped_transactions, Array
  serialize :bofa_data, Array
  has_many :sub_orders
  
  def import_braintree(file)
    CSV.foreach(file, headers: true) do |row|
      self.braintree_transactions << {trans_id: row[0], disb_date: Date.strptime(row[8],'%m/%d/%y'), amt: row[12].to_f }
    end
    self.braintree_transactions.sort_by!{ |trans| trans[:disb_date] }
    self.save
  end
  def import_bofa(file)
    CSV.foreach(file, headers: true) do |row|
      self.bofa_data << {disb_date: Date.strptime(row[0], '%m/%d/%Y'), amt: row[1].to_f }
    end
    self.bofa_data.sort_by!{|date| date[:disb_date]}
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
    self.grouped_transactions.sort_by!{ |date| date[:disb_date] }
    self.save
  end
  
  def update_transactions(bt_disb,bofa_disb)
    grouped_transactions = []
    bt_disb.each do |index|
      grouped_transactions << self.grouped_transactions[index.to_i]
    end
    self.grouped_transactions = grouped_transactions
    bofa_data = []
    bofa_disb.each do |index|
      bofa_data << self.bofa_data[index.to_i]
    end
    self.bofa_data = bofa_data
    self.save
  end
  
  def calc_net_amt(amt)
    fee = (amt * 0.029) + 0.30
    amt -= fee
    amt.round(2)
  end
end