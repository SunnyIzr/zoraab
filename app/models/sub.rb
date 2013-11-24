class Sub < ActiveRecord::Base
  has_and_belongs_to_many :prefs
  has_many :orders
  validates_presence_of :cid

  def name(response)
    customer(response)['first_name'] + ' ' + customer(response)['last_name']
  end

  def email(response)
    customer(response)['email']
  end

  def plan(response)
    product(response)['name']
  end

  def status(response)
    response['state']
  end

  def start_date(response)
    response['created_at'].strftime('%d %b %Y')
  end

  def shipping_address(response)
    {   :name => name(response),
        :address => customer(response)['address'],
        :address2 => customer(response)['address_2'],
        :city => customer(response)['city'],
        :state => customer(response)['state'],
        :zip => customer(response)['zip'],
        :country => customer(response)['country'],
        :phone => customer(response)['phone']
      }
  end

  def billing_address(response)
    {   :name => billing(response)['first_name'] + ' ' + billing(response)['last_name'],
        :address => billing(response)['billing_address'],
        :address2 => billing(response)['billing_address_2'],
        :city => billing(response)['billing_city'],
        :state => billing(response)['billing_state'],
        :zip => billing(response)['billing_zip'],
        :country => billing(response)['billing_country'],
        :phone => billing(response)['billing_phone']
      }
  end

  def chargify
    Chargify::Subscription.find(cid).attributes
  end

  private

  def customer(response)
    response['customer'].attributes
  end

  def product(response)
    response['product'].attributes
  end

  def billing(response)
    response['credit_card'].attributes
  end
end
