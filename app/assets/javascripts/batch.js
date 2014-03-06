var BatchController = {
  init: function() {
    this.generateBatchBtn()
    this.confirmBatchBtn()
    this.saveBatchBtn()
    this.batchSendToShipStation()
    this.sendAlltoShipStation()

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

  }
}

var BatchModel = {
  ordersToBeSent:[],
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
  }
}

var BatchView = {
  startLoaderforShipping: function(orderId) {
    $('td[data-orderid="'+orderId+'"] > div').hide()
    $('td[data-orderid="'+orderId+'"] > center > img').show()
  },
  showSuccessfulShip: function(orderId) {
    $('td[data-orderid="'+orderId+'"]').html('Unshipped')
  },
  showUnsuccessfulShip: function(orderId) {
    $('td[data-orderid="'+orderId+'"] > center > img').hide()
    $('td[data-orderid="'+orderId+'"] > div').show()
    $('td[data-orderid="'+orderId+'"] > div > p').html('<span class=ship-error>Fail!</span>')
  }
}
