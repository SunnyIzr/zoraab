var BatchController = {
  init: function() {
    this.generateBatchBtn()
    this.confirmBatchBtn()
    this.saveBatchBtn()
    this.batchSendToShipStation()
    this.sendAlltoShipStation()
    this.sendToShopifyBtn()
    this.sendAlltoShopify()

  },
  generateBatchBtn: function() {
    $('.generate-batch').click(function(event) {
      event.preventDefault();
      $('.generate-button').click()

    })
  },
  confirmBatchBtn: function() {
  $('.confirm-batch').click(function(event) {
      event.preventDefault();
      $('.confirm-order').click()
      $('.confirm-batch').hide()
      $('.save-batch').show()
    })
  },
  saveBatchBtn: function() {
    $('.save-batch').click(function(event) {
      event.preventDefault();
      $('.save-order').click()
      $('.save-batch').hide()
      $('.view-batch').show()
    })
  },
  batchSendToShipStation: function() {
    $('.batch-send-to-shipstation').click(function(event){
      event.preventDefault();
      orderId = $(this).data('orderid')
      BatchView.startLoaderforShipping(orderId)
      BatchModel.sendToShipstation(orderId)
    })
  },
  sendAlltoShipStation: function() {
    $('.send-all-to-shipstation').click(function(event) {
      event.preventDefault();
      orderBtns = $('.batch-send-to-shipstation:visible')
      $.each(orderBtns,function(i,v) {
        orderId = $(v).data('orderid')
        BatchModel.ordersToBeSent.push(orderId)
        BatchView.startLoaderforShipping(orderId)
      })
      BatchModel.runShipstationQueue()
    })

  },
  sendToShopifyBtn: function() {
    $('.send-to-shopify').click(function(event) {
      event.preventDefault();
      orderId = $(this).data('orderid')
      BatchView.startLoaderforShopify(orderId)
      BatchModel.sendOrderToShopify(orderId)
    })
  },
  sendAlltoShopify: function() {
    $('.send-all-to-shopify').click(function(event) {
      event.preventDefault();
      orderBtns = $('.send-to-shopify:visible')
      $.each(orderBtns,function(i,v) {
        orderId = $(v).data('orderid')
        BatchModel.ordersToBeSentToShopify.push(orderId)
        BatchView.startLoaderforShopify(orderId)
      })
      BatchModel.runShopifyQueue()
    })

  },
}

var BatchModel = {
  ordersToBeSent:[],
  ordersToBeSentToShopify: [],
  sendToShipstation: function(orderId) {
    path = '/send-to-shipstation'
    $.post(path,{order_id: orderId}).done(function(data) {
      BatchView.showSuccessfulShip(orderId)
    }).fail(function(data) {
      BatchView.showUnsuccessfulShip(orderId)
    })
  },
  runShipstationQueue: function() {
    if (BatchModel.ordersToBeSent.length > 0) {
      orderId = BatchModel.ordersToBeSent.shift()
      path = '/send-to-shipstation'
      $.post(path,{order_id: orderId}).done(function(data) {
        BatchView.showSuccessfulShip(orderId)
      }).fail(function(data) {
        BatchView.showUnsuccessfulShip(orderId)
      }).always(function(data) {
        BatchModel.runShipstationQueue()
      })
    }
  },
  sendOrderToShopify: function(orderId) {
    path = '/send-to-shopify/' + orderId
    $.post(path,{order_id: orderId}).done(function(data) {
      BatchView.showSuccessfulShopify(orderId)
    }).fail(function(data) {
      BatchView.showUnsuccessfulShopify(orderId)
    })
  },
  runShopifyQueue: function() {
    if (BatchModel.ordersToBeSentToShopify.length > 0) {
      orderId = BatchModel.ordersToBeSentToShopify.shift()
      path = '/send-to-shopify/' + orderId
      $.post(path,{order_id: orderId}).done(function(data) {
        BatchView.showSuccessfulShopify(orderId)
      }).fail(function(data) {
        BatchView.showUnsuccessfulShopify(orderId)
      }).always(function(data) {
        BatchModel.runShopifyQueue()
      })
    }
  }
}

var BatchView = {
  startLoaderforShipping: function(orderId) {
    $('td[data-orderid="'+orderId+'"].ship > div').hide()
    $('td[data-orderid="'+orderId+'"].ship > center > img').show()
  },
  startLoaderforShopify: function(orderId) {
    $('td[data-orderid="'+orderId+'"].shopify > div').hide()
    $('td[data-orderid="'+orderId+'"].shopify > center > img').show()

  },
  showSuccessfulShip: function(orderId) {
    $('td[data-orderid="'+orderId+'"].ship').html('Unshipped')
  },
  showUnsuccessfulShip: function(orderId) {
    $('td[data-orderid="'+orderId+'"].ship > center > img').hide()
    $('td[data-orderid="'+orderId+'"].ship > div').show()
    $('td[data-orderid="'+orderId+'"].ship > div > p').html('<span class=ship-error>Fail!</span>')
  },
  showSuccessfulShopify: function(orderId) {
    $('td[data-orderid="'+orderId+'"].shopify').html('Sent')
  },
  showUnsuccessfulShopify: function(orderId) {
    $('td[data-orderid="'+orderId+'"].shopify > center > img').hide()
    $('td[data-orderid="'+orderId+'"].shopify > div').show()
    $('td[data-orderid="'+orderId+'"].shopify > div > p').html('<span class=ship-error>Fail!</span>')
  }
}
