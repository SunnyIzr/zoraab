var InvoiceController = {
  init: function() {
    this.calcLineItem()
    this.calcTotal()
    this.removeLineItem()
    this.checkItem()
    this.checkItems()
    this.createItems()
    this.inputPrefix()
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
  },
  checkItems: function() {
    $(document).on('click', '#check-qb-for-products', function(event) {
      event.preventDefault();
      InvoiceView.startLoader()
      invoiceId = $(this).data('invoiceid')
      missingSkus = InvoiceModel.checkItems(invoiceId)
    })
  },
  createItems: function() {
    $(document).on('click', '#create-qb-products', function(event) {
      event.preventDefault();
      InvoiceView.startLoader()
      invoiceId = $(this).data('invoiceid')
      InvoiceModel.createItems(invoiceId)
    })
  },
  inputPrefix: function() {
    $(document).on('change','#invoice_vendor', function(event) {
      vendor = $('#invoice_vendor').val()
      InvoiceModel.getPrefix(vendor)
    })
  }
}

var InvoiceModel = {
  currentPrefix: 'FT_',
  calcLineItem: function(rate,q){
    total = rate * q
    return total
  },
  calcTotal: function() {
    total = 0
    shipping = parseFloat($('#invoice_shipping').val())
    discount = parseFloat($('#invoice_discount').val())
    total += shipping
    total -= discount
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
    },
  checkItems: function(invoiceId) {
    $.post('/check-all-products', {id: invoiceId}, function(missingSkus) {
      if (missingSkus.length > 0 ){
        InvoiceView.itemsDontAllExist(missingSkus,invoiceId)
      }
      else {
        InvoiceView.itemsAllExist()
      }
    })
  },
  createItems: function(invoiceId) {
    $.post('/create-all-products', {id: invoiceId}, function(response) {
    }).done(function() {
      console.log('done!!')
      missingSkus = []
      InvoiceView.itemsDontAllExist(missingSkus,invoiceId)
    })
  },
  getPrefix: function(vendor) {
    $.get('/vendors', function(response) {
      prefix = response[vendor]
      InvoiceModel.currentPrefix = prefix+'_'
      InvoiceView.changePrefixes()
    })
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
  },
  startLoader: function() {
    $('.check-qb').html("<img src='/assets/loader.gif'>")
  },
  hideLoader: function() {
    $('.check-qb > img').hide()
  },
  itemsAllExist: function() {
    this.hideLoader()
    $('.check-qb').html('All Products on QBO')
    $('.send-to-qb').show()
  },
  itemsDontAllExist: function(missingSkus,invoiceId){
    this.hideLoader()
    $('.check-qb').append("<a href='#' id='create-qb-products' data-invoiceid='"+ invoiceId + "' class='button'> Create QBO Products </a><br><a href='#' id='check-qb-for-products' data-invoiceid='"+ invoiceId + "' class='button'> Check QBO </a><br>")
    $('.check-qb').append('Missing Skus:')
    $.each(missingSkus, function(e,value) {
      el = '<li>' + value + '</li>'
      $('.check-qb').append(el)
    })
  },
  changePrefixes: function() {
    $('.sku > input').val(InvoiceModel.currentPrefix)
  }
  

}
