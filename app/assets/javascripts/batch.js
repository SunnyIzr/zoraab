var BatchController = {
  init: function() {
    this.generateBatchBtn()
    this.confirmBatchBtn()
    this.saveBatchBtn()
    this.batchSendToShipStation()

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
  }
}

var BatchModel = {
  sendToShipstation: function(orderId) {
    path = '/send-to-shipstation'
    $.post(path,{order_id: orderId}).done(function(data) {
      BatchView.showSuccessfulShip(orderId)
    }).fail(function(data) {
      BatchView.showUnsuccessfulShip(orderId)
    })
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
