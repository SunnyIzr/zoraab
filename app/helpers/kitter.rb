# The Kitter Module holds the algorithm for Subscription Selections.
# - Inputs: Sub ID, Last Product Shown
# - Outputs: Array of Products
# The Kitter will assemble of an array of products by alternating between sub preferences picking the first product

module Kitter
  extend self

  def suggest_prod_ids(sub_id)
    suggestions = generate_kitter_suggestions(sub_id).compact
    prod_ids = []
    suggestions.each_with_index do |product,indx|
      prod_ids << product.id
    end
    prod_ids
  end

  def generate_kitter_suggestions(sub_id)
    prefs = Sub.find(sub_id).prefs.map {|pref| pref.pref}
    prod_lists = []
    prefs.each do |pref|
      non_dupe_list = remove_dupes(pref, sub_id)
      prod_lists << non_dupe_list
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

  def remove_dupes(pref,sub_id)
    list = []
    Product.filter(pref).each do |prod|
      list << prod if !Sub.find(sub_id).order_history.include?(prod.sku)
    end
    list
  end
end
