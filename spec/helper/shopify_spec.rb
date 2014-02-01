require 'spec_helper'

describe Shopify do
  it 'should populate a hash of information from Shopify' do
    sku = 'ms-at707'
    data = Shopify.data(sku)

    expect(data[:sku]).to eq('ms-at707')
    expect(data[:title]).to eq('Antiquity')
    expect(data[:price]).to eq(11)
    expect(data[:vendor]).to eq('Mint Socks')
    expect(data[:tags]).to eq('Blue, Cotton, Crew, Fashion Socks, Fun Socks, Men, Mint Socks, New, Print')
    expect(data[:pic]).to eq('http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047')
    expect(data[:small_pic]).to eq('http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047')
  end

  it 'should indicate whether something is published' do
    sku = 'ms-at707'
    prod = ShopifyAPI::Product.find(:all, :params => {'handle' => sku}).first

    expect(Shopify.published?(prod)).to eq(true)
  end

  it 'should indicate if something is NOT on sale' do
    sku = 'ms-at707'
    prod = ShopifyAPI::Product.find(:all, :params => {'handle' => sku}).first

    expect(Shopify.not_sale?(prod)).to eq(true)
  end

  it 'should obtain handle of a product' do
    sku = 'ms-at707'
    prod = ShopifyAPI::Product.find(:all, :params => {'handle' => sku}).first

    expect(Shopify.handle_sku(prod)).to eq("ms-at707")
  end

  it 'should obtain current inv quantity that is an integer' do
    sku = 'ms-at707'
    prod = ShopifyAPI::Product.find(:all, :params => {'handle' => sku}).first

    expect(Shopify.q(prod).class).to eq(Fixnum)
  end

  it 'should show associated prefs in required syntax' do
    sku = 'ms-at707'
    prod = ShopifyAPI::Product.find(:all, :params => {'handle' => sku}).first

    expect(Shopify.prefs(prod)).to eq(['fashion','fun'])
  end
end
