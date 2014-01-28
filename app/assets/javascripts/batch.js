var BatchController = {
  init: function() {
    this.generateBatchBtn()
    this.confirmBatchBtn()
    this.saveBatchBtn()

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
  }
}

var BatchView = {

}
