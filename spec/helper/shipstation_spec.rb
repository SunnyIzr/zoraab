require 'spec_helper'

describe Shipstation do
  let (:sub) {FactoryGirl.create(:sub)}
  let (:order1) {FactoryGirl.create(:order)}
  let (:product1) {FactoryGirl.create(:product)}
  let (:product2) {FactoryGirl.create(:product)}

  it 'should create blank order template' do
    order = Shipstation.blank_order
    expect(order.class).to eq(SHIP::Order)
    expect(order.OrderID).to eq(nil)
    expect(order.SellerID).to eq(103618)
    expect(order.StoreID).to eq(16357)
    expect(order.MarketplaceID).to eq(0)
    expect(order.OrderStatusID).to eq(2)
    expect(order.CustomerID).to eq(nil)
    expect(order.ShipPhone).to eq(nil)
    expect(order.ShipCompany).to eq(nil)
    expect(order.PackageTypeID).to eq(nil)
    expect(order.ShipDate).to eq(nil)
    expect(order.ShippingAmount).to eq(BigDecimal(0))
    expect(order.OrderTotal).to eq(BigDecimal(0))
    expect(order.Username).to eq(nil)
    expect(order.NotesFromBuyer).to eq(nil)
    expect(order.NotesToBuyer).to eq(nil)
    expect(order.InternalNotes).to eq(nil)
    expect(order.WeightOz).to eq(0)
    expect(order.Width).to eq(BigDecimal(0))
    expect(order.Length).to eq(BigDecimal(0))
    expect(order.Height).to eq(BigDecimal(0))
    expect(order.Active).to eq("false")
    expect(order.ServiceID).to eq(nil)
    expect(order.ShipStreet3).to eq(nil)
    expect(order.AmountPaid).to eq(BigDecimal(0))
    expect(order.InsuredValue).to eq(BigDecimal(0))
    expect(order.InsuranceProvider).to eq("0")
    expect(order.InsuranceCost).to eq(BigDecimal(0))
    expect(order.ProviderID).to eq(nil)
    expect(order.Confirmation).to eq("0")
    expect(order.ConfirmationCost).to eq(BigDecimal(0))
    expect(order.HoldUntil).to eq(nil)
    expect(order.RequestedShippingService).to eq(nil)
    expect(order.WarehouseID).to eq(5295)
    expect(order.CustomsContents).to eq(nil)
    expect(order.NonDelivery).to eq(nil)
    expect(order.ResidentialIndicator).to eq("R")
    expect(order.ExternalUrl).to eq(nil)
    expect(order.AdditionalHandling).to eq("false")
    expect(order.SaturdayDelivery).to eq("false")
    expect(order.RateError).to eq(nil)
    expect(order.OtherCost).to eq(BigDecimal(0))
    expect(order.ExternalPaymentID).to eq(nil)
    expect(order.NonMachinable).to eq("false")
    expect(order.ShowPostage).to eq("false")
    expect(order.PackingSlipID).to eq(nil)
    expect(order.EmailTemplateID).to eq(nil)
    expect(order.RequestedServiceID).to eq(nil)
    expect(order.Gift).to eq("false")
    expect(order.GiftMessage).to eq(nil)
    expect(order.ExportStatus).to eq(nil)
    expect(order.TaxAmount).to eq(BigDecimal(0))
    expect(order.CustomField1).to eq(nil)
    expect(order.CustomField2).to eq(nil)
    expect(order.CustomField3).to eq(nil)
    expect(order.AssignedUser).to eq(nil)
    expect(order.Source).to eq(nil)

  end

  it 'should create blank order item template' do
    order_item = Shipstation.blank_order_item
    expect(order_item.class).to eq(SHIP::OrderItem)
    expect(order_item.OrderItemID).to eq(nil)
    expect(order_item.ExternalID).to eq(nil)
    expect(order_item.Adjustment).to eq("false")
    expect(order_item.UPC).to eq(nil)
    expect(order_item.Description).to eq("")
    expect(order_item.UnitPrice).to eq(BigDecimal(0))
    expect(order_item.ExtendedPrice).to eq(BigDecimal(0))
    expect(order_item.UnitCost).to eq(nil)
    expect(order_item.Quantity).to eq(1)
    expect(order_item.TaxAmount).to eq(nil)
    expect(order_item.ShippingAmount).to eq(nil)
    expect(order_item.WeightOz).to eq(nil)
    expect(order_item.ItemUrl).to eq(nil)
    expect(order_item.WarehouseLocation).to eq(nil)
    expect(order_item.Options).to eq(nil)
    expect(order_item.Inactive).to eq("false")
    expect(order_item.OriginalImportKey).to eq(nil)
  end

  it 'should create a shipstation order with specified fields' do
    order1.sub = sub
    order1.set_order_details
    order1.order_number = 'testing'
    order1.save

    shipstation_order = Shipstation.create_order(order1)
    expect(shipstation_order.OrderNumber).to eq('testing')
    expect(shipstation_order.ShipName).to eq('SunnyShip IsraniShip')
    expect(shipstation_order.ShipStreet1).to eq('123 Shipping Street')
    expect(shipstation_order.ShipStreet2).to eq(nil)
    expect(shipstation_order.ShipCity).to eq('Ship City')
    expect(shipstation_order.ShipState).to eq('ON')
    expect(shipstation_order.ShipPostalCode).to eq('12345')
    expect(shipstation_order.ShipCountryCode).to eq('CA')
    expect(shipstation_order.BuyerEmail).to eq('sunny@zoraab.com')
    expect(shipstation_order.BuyerName).to eq('SunnyShip IsraniShip')
    expect(shipstation_order.ImportKey).to eq('testing')
  end

  it 'should create a shipstation order_item with specified fields' do
    order1.sub = sub
    order1.set_order_details
    order1.order_number = 'testing'
    product1.sku = 'ms-at707'
    product1.save
    order1.products << product1
    shipstation_order = Shipstation.create_order(order1)
    shipstation_order.OrderID = 'testing'
    shipstation_order_item = Shipstation.create_order_item(order1,product1,shipstation_order)

    expect(shipstation_order_item.OrderID).to eq('testing')
    expect(shipstation_order_item.SKU).to eq('ms-at707')
    expect(shipstation_order_item.ThumbnailUrl).to eq('http://cdn.shopify.com/s/files/1/0127/4312/products/MS-AT707.jpg?v=1385515047')
  end
end
