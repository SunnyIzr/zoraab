String.prototype.capitalize = function() {
    return this.replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
};

var QbController = {
  init: function(){
    this.pullOrderBtn()
    this.uploadToQbBtn()
    
  },
  pullOrderBtn: function(){
   $('.pull-orders').click(function(e){
      e.preventDefault();
      $(".loading").show()
      $('tbody').html('')
      QbModel.pullOrders()
   }) 
  },
  uploadToQbBtn: function(){
    $('.upload-to-qb').click(function(e){
      e.preventDefault();
      orders = $.map($('form').serializeArray(),function(v,i){return v.value})
      $.each(orders,function(k,v){
        QbModel.sendOrderToQb(QbModel.orders[v])
      })
    })
  }
}

var QbModel = {
  pullOrders: function(){
    $.post('/shopify-orders', {start_date: $('#start_date').val(), end_date: $('#end_date').val()}, function(res){
      QbModel.orders = res
      $(".loading").hide()
      QbView.renderOrders()
    })
  },
  orders: null,
  sendOrderToQb: function(order){
    $.post('/upload-order-to-qb',{order: order},function(res){
      console.log(res)
    })
  }
}

var QbView = {
  renderOrders: function(){
    $.each(QbModel.orders,function(key,value){
      QbView.appendOrder(value)
    })
  },
  appendOrder: function(order){
    string = order.created_at
    order.created_at = new Date(string)
    d = order.created_at
    el = '<tr></tr>'
    el = $(el).append('<td><input id="orders_" name="orders[]" type="checkbox" value="'+order.number+'"></td>')
    el = el.append('<td>'+order.number+'</td>')
    el = el.append('<td>'+d.getMonth()+'/'+d.getDate()+'/'+d.getFullYear()+'</td>')
    el = el.append('<td>'+order.billing_address.name.capitalize()+'</td>')
    el = el.append('<td>$'+order.total+'</td>')
    el = el.append('<td></td>')
    $('tbody').append(el)
  }
}