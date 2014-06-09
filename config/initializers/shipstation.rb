SHIPSTATION = OData::Service.new 'https://data3.shipstation.com/1.3/', {:username => ENV['SHIP_LOGIN'], :password => ENV['SHIP_PW'], :namespace => 'SHIP'}
