var InvoiceController = {
  init: function() {
    this.calcLineItem()
    this.calcTotal()
  },
  calcLineItem: function() {
    $('.calc-line-item').click(function(event) {
      event.preventDefault();
      el = $(this).parent().parent()
      rate = el.find('.rate > input').val()
      q = el.find('.q > input').val()
      total = InvoiceModel.calcLineItem(rate,q,this)
      InvoiceView.calcLineItem(total,el.find('.total'))
    })
  },
  calcTotal: function() {
    $('#calc-total').click(function(event) {
      $('.calc-line-item').click()
      event.preventDefault();
      total = InvoiceModel.calcTotal()
      InvoiceView.calcTotal(total)
    })
  }
}

var InvoiceModel = {
  calcLineItem: function(rate,q){
    total = rate * q
    return total
  },
  calcTotal: function() {
    total = 0
    shipping = parseFloat($('#invoice_shipping').val())
    total += shipping
    $.map( $('.total'), function(n) {
      total += parseFloat($(n).html().slice(1))
    });
    return total
  }

}
var InvoiceView = {
  calcLineItem: function(total,el) {
    el.html('$'+total.toFixed(2))
  },
  calcTotal: function(total){
    $('#invoice-total').html('$'+total.toFixed(2))
  }

}
