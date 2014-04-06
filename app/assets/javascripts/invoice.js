var InvoiceController = {
  init: function() {
    this.calcLineItem()
    this.calcTotal()
    this.removeLineItem()
    this.checkItem()
  },
  calcLineItem: function() {
    $(document).on('click', '.calc-line-item', function(event) {
      event.preventDefault();
      el = $(this).parent().parent()
      rate = el.find('.rate > input').val()
      q = el.find('.q > input').val()
      total = InvoiceModel.calcLineItem(rate,q,this)
      InvoiceView.calcLineItem(total,el.find('.total'))
    })
  },
  calcTotal: function() {
    $(document).on('click','#calc-total',function(event) {
      $('.calc-line-item').click()
      event.preventDefault();
      total = InvoiceModel.calcTotal()
      InvoiceView.calcTotal(total)
    })
  },
  removeLineItem: function() {
    $(document).on('click','.remove-line-item',function(event) {
      event.preventDefault();
      $(this).parent().parent().remove()
    })
  },
  checkItem: function() {
    $(document).on('click','.check-item', function(event) {
      event.preventDefault();
      el = $(this).parent().parent()
      sku = $(el).parent().parent().find('.sku > input').val()
      InvoiceModel.checkItem(sku,el)
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
  },
  checkItem: function(sku,el) {
    $.post('/check-product', {sku: sku}, function(response) {
        if (response == true) {
          InvoiceView.itemExists(el)
        }
        else {
          InvoiceView.itemNotExists(el)
        }
      });
    }
}
var InvoiceView = {
  calcLineItem: function(total,el) {
    el.html('$'+total.toFixed(2))
  },
  calcTotal: function(total){
    $('#invoice-total').html('$'+total.toFixed(2))
  },
  itemExists: function(el) {
    el.css('background-color','#cbffdc')
  },
  itemNotExists: function(el) {
    el.css('background-color','#fca1a3')
  }

}
