var BatchController = {
  init: function() {
    this.generateBatchBtn()
    this.confirmBatchBtn()
    this.saveBatchBtn()

  },
  generateBatchBtn: function() {
    $('.generate-batch').click(function() {
      $('.generate-button').click()

    })
  },
  confirmBatchBtn: function() {
  $('.confirm-batch').click(function() {
      $('.confirm-order').click()
      $('.confirm-batch').hide()
      $('.save-batch').show()
    })
  },
  saveBatchBtn: function() {
    $('.save-batch').click(function() {
      $('.save-order').click()
      $('.save-batch').hide()
      $('.view-batch').show()
    })
  }
}

var BatchView = {

}
