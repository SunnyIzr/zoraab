
$(function(){ $(document).foundation(); });

$(document).ready(function() {
    shopifySync();
    longLoad();
    OrdersController.init()
    BatchController.init()
    DashboardController.init()
    InvoiceController.init()
    QbController.init()
    BraintreeRecController.init()

  });


function shopifySync() {
  $('a#shopify_sync').click(function(event) {
    event.preventDefault();
    window.location.href = '/sync'

  })
}

function longLoad() {
  $('.long-load').click(function(event) {
    revealLoader()

  })
}

function revealLoader() {
  $('.overlay').addClass('overlay-show')
  $('.overlay').addClass('overlay-impt')
  $('.loader').addClass('loader-show')
  $('#ballWrapper').removeClass('ballWrapper')
}

