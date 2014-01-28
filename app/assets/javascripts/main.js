
$(function(){ $(document).foundation(); });

$(document).ready(function() {
    shopifySync();
    fulfillRecurSubs();
    OrdersController.init()
    BatchController.init()
    DashboardController.init()

  });


function shopifySync() {
  $('a#shopify_sync').click(function(event) {
    event.preventDefault();
    $('.overlay').show();
    $('#loader').show();
    window.location.href = '/sync'

  })
}

function fulfillRecurSubs () {
  $('.retrieve-recurring-subs').click(function() {
    $('.overlay').show();
    $('#loader').show();
  })

}
