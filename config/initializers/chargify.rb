Chargify.configure do |c|
  c.api_key = ENV['CHARGIFY_API_KEY']
  c.site = ENV['CHARGIFY_SITE']
end