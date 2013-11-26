# The Kitter Module holds the algorithm for Subscription Selections.
# - Inputs: Sub ID, Last Product Shown
# - Outputs: Array of Products
# The Kitter will assemble of an array of products by alternating between sub preferences picking the first product

module Kitter
  extend self

  def generate_kitter_suggestions(sub_id)
    prefs = Sub.find(sub_id).prefs.map {|pref| pref.pref}
    prod_lists = []
    prefs.each do |pref|
      prod_lists << Product.filter(pref)
    end
    alt_between_lists(prod_lists)
  end


  def alt_between_lists(ary_of_lists)
    case ary_of_lists.count
    when 1
      ary_of_lists.flatten.uniq
    when 2
      ary_of_lists.first.zip(ary_of_lists[1]).flatten.uniq
    when 3
      ary_of_lists.first.zip(ary_of_lists[1],ary_of_lists[2]).flatten.uniq
    when 4
      ary_of_lists.first.zip(ary_of_lists[1],ary_of_lists[2],ary_of_lists[3]).flatten.uniq
    end

  end

end
