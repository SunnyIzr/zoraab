module Money
  include ActionView::Helpers::NumberHelper
  extend self
  def amt(amt)
    number_to_currency(amt)
  end
end