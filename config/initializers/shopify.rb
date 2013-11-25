ShopifyAPI::Session.setup({:api_key => ENV['SHOPIFY_API_KEY'], :secret => ENV['SHOPIFY_SECRET']})
session = ShopifyAPI::Session.new('zoraab.myshopify.com', ENV['SHOPIFY_PW'])
session.valid?
ShopifyAPI::Base.activate_session(session)
