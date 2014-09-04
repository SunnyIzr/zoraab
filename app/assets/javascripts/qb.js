String.prototype.capitalize = function() {
    return this.replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
};

var QbController = {
  init: function(){
    this.pullOrderBtn()
    this.uploadToQbBtn()
    this.checkAllBox()
    
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
      QbView.loadingOrders(orders)
      $.each(orders,function(k,v){
        QbModel.sendOrderToQb(QbModel.orders[v])
      })
    })
  },
  checkAllBox: function(){
    $('#all_orders').click(function(e){
      if(this.checked){
        $.each($('input[name="orders[]"]'),function(k,v){
          this.checked = true
        })
      }else{
        $.each($('input[name="orders[]"]'),function(k,v){
          this.checked = false
        })
      }
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
    }).success(function(res){
      $('#'+order.number+' .status').html(res.message)
      }).error(function(res){
      $('#'+order.number+' .status').html('Fail')
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
    d = new Date(string)
    el = '<tr id="'+order.number+'"></tr>'
    el = $(el).append('<td><input id="orders_" name="orders[]" type="checkbox" value="'+order.number+'"></td>')
    el = el.append('<td>'+order.number+'</td>')
    el = el.append('<td>'+(d.getMonth()+1)+'/'+d.getDate()+'/'+d.getFullYear()+'</td>')
    el = el.append('<td>'+order.billing_address.name.capitalize()+'</td>')
    el = el.append('<td>$'+order.total+'</td>')
    el = el.append('<td class="status"></td>')
    $('tbody').append(el)
  },
  loadingOrders: function(orders){
    $.each(orders, function(k,v){
      $('#'+v+' .status').html("<img src='/assets/loader.gif' class='loader-order'>")
    })
  }
}