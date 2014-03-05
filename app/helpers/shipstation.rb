module Shipstation
  extend self


  def get_order(ssid)
    if ssid != nil
        SHIPSTATION.Orders.filter("OrderID eq " + ssid.to_s)
        order = SHIPSTATION.execute
        return order[0]
    else
        return nil
    end
  end

  def get_order_by_order_number(order_number)
    SHIPSTATION.Orders.filter("OrderNumber eq '" + order_number + "'")
    SHIPSTATION.execute[0]
  end

  def send_order(order)
    if get_order_by_order_number(order.order_number).nil?
        ss_order = create_order(order)
        SHIPSTATION.AddToOrders(ss_order)
        created_order = SHIPSTATION.save_changes
        order.products.each do |product|
          order_item = create_order_item(order,product,created_order[0])
          SHIPSTATION.AddToOrderItems(order_item)
          SHIPSTATION.save_changes
        end
        created_order[0]
    end
  end

  def create_order(order)
    shipstation_order = blank_order
    shipstation_order.OrderDate = order.created_at
    shipstation_order.PayDate = order.created_at
    # shipstation_order.OrderNumber = order.order_number
    shipstation_order.OrderNumber = 'TESTING!!!'
    shipstation_order.ShipName = order.name
    shipstation_order.ShipStreet1 = order.address
    shipstation_order.ShipStreet2 = order.address2
    shipstation_order.ShipCity = order.city
    shipstation_order.ShipState = order.state
    shipstation_order.ShipPostalCode = order.zip
    shipstation_order.ShipCountryCode = order.country
    shipstation_order.BuyerEmail = order.email
    shipstation_order.BuyerName = order.name
    shipstation_order.ImportKey=order.order_number
    shipstation_order.CreateDate = Time.new
    shipstation_order.ModifyDate = Time.new
    shipstation_order
  end

  def blank_order
    order = SHIP::Order.new
    order.OrderID=nil
    order.SellerID=103618
    order.StoreID=16357
    order.MarketplaceID=0
    order.OrderStatusID=2
    order.CustomerID=nil
    order.ShipPhone = nil
    order.ShipCompany = nil
    order.PackageTypeID=nil
    order.ShipDate=nil
    order.ShippingAmount=BigDecimal(0)
    order.OrderTotal=BigDecimal(0)
    order.Username=nil
    order.NotesFromBuyer=nil
    order.NotesToBuyer=nil
    order.InternalNotes=nil
    order.WeightOz=0
    order.Width=BigDecimal(0)
    order.Length=BigDecimal(0)
    order.Height=BigDecimal(0)
    order.Active="false"
    order.ServiceID=nil
    order.ShipStreet3=nil
    order.AmountPaid=BigDecimal(0)
    order.InsuredValue=BigDecimal(0)
    order.InsuranceProvider="0"
    order.InsuranceCost=BigDecimal(0)
    order.ProviderID=nil
    order.Confirmation="0"
    order.ConfirmationCost=BigDecimal(0)
    order.HoldUntil=nil
    order.RequestedShippingService=nil
    order.WarehouseID=5295
    order.CustomsContents=nil
    order.NonDelivery=nil
    order.ResidentialIndicator="R"
    order.ExternalUrl=nil
    order.AdditionalHandling="false"
    order.SaturdayDelivery="false"
    order.RateError=nil
    order.OtherCost=BigDecimal(0)
    order.ExternalPaymentID=nil
    order.NonMachinable="false"
    order.ShowPostage="false"
    order.PackingSlipID=nil
    order.EmailTemplateID=nil
    order.RequestedServiceID=nil
    order.Gift="false"
    order.GiftMessage=nil
    order.ExportStatus=nil
    order.TaxAmount=BigDecimal(0)
    order.CustomField1=nil
    order.CustomField2=nil
    order.CustomField3=nil
    order.AssignedUser=nil
    order.Source=nil
    order
  end

  def create_order_item(order,item,ssorder)
    shipstation_order_item = blank_order_item
    shipstation_order_item.OrderID = ssorder.OrderID
    shipstation_order_item.SKU = item.sku
    shipstation_order_item.ThumbnailUrl = Shopify.data(item.sku)[:small_pic]
    shipstation_order_item.CreateDate = order.created_at
    shipstation_order_item.ModifyDate = order.created_at
    shipstation_order_item
  end

  def blank_order_item
    order_item = SHIP::OrderItem.new
    order_item.OrderItemID=nil
    order_item.ExternalID=nil
    order_item.Adjustment="false"
    order_item.UPC=nil
    order_item.Description=""
    order_item.UnitPrice=BigDecimal(0)
    order_item.ExtendedPrice=BigDecimal(0)
    order_item.UnitCost=nil
    order_item.Quantity=1
    order_item.TaxAmount=nil
    order_item.ShippingAmount=nil
    order_item.WeightOz=nil
    order_item.ItemUrl=nil
    order_item.WarehouseLocation=nil
    order_item.Options=nil
    order_item.Inactive="false"
    order_item.OriginalImportKey=nil
    order_item
  end
end
