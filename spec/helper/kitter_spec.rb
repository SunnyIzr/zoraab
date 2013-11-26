require 'spec_helper'

describe Kitter do
  let (:dress_prod_list) {%w[D0 D1 D2 D3]}
  let (:fashion_prod_list) {%w[F0 F1 F2 F3]}
  let (:casual_prod_list) {%w[C0 C1 C2 C3]}

  it "should produce the inputted list of there is only one list" do
    expect(Kitter.alt_between_lists([dress_prod_list])).to eq (%w[D0 D1 D2 D3])
  end

  it "should produce an array that alternates between an array of 2 separate product lists" do
    expect(Kitter.alt_between_lists([dress_prod_list,fashion_prod_list])).to eq (%w[D0 F0 D1 F1 D2 F2 D3 F3])
  end

  it "should produce an array that alternates between an array of greater than 2 separate product lists" do
    expect(Kitter.alt_between_lists([dress_prod_list,fashion_prod_list, casual_prod_list])).to eq (%w[D0 F0 C0 D1 F1 C1 D2 F2 C2 D3 F3 C3])
  end
end
