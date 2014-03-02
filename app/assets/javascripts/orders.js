var OrdersController = {
  init: function() {
    this.genButton()
    this.inputKeyUp()
    this.nextProductButton()
    this.prevProductButton()
    this.deleteOrderButton()
    this.confirmOrderButton()
    this.saveOrderButton()
    this.saveOrderLoadButton()
    this.sendToShipstationButton();
  },
  genButton: function() {
    $('.generate-button').click(function(event){
      event.preventDefault();
      subId = $(this).attr('data-subid')
      OrdersView.showAllLoaders(subId)
      OrdersModel.generateKitterRecs(subId)
      OrdersModel.addFirstRecsToPos(subId)
      OrdersView.inputFirstRecs(subId)
      $('.arrows').show();
      $('.preview-image').show();
    })
  },
  inputKeyUp: function() {
    $('input').keyup(function() {
      subId = $(this).parent().parent().parent().data('sub')
      pos = $(this).parent().parent().data('item')
      OrdersView.prevImg(subId,pos)
      OrdersModel.checkDupe(subId,pos)
    })
  },
  nextProductButton: function() {
    $('.next-link').click(function(event) {
      event.preventDefault();
      subId = $(this).data('subid')
      pos = $(this).data('item')
      OrdersModel.nextRec(subId,pos)
      OrdersView.updateInputTag(subId,pos)
    })
  },
  prevProductButton: function() {
    $('.prev-link').click(function(event) {
      event.preventDefault();
      subId = $(this).data('subid')
      pos = $(this).data('item')
      OrdersModel.prevRec(subId,pos)
      OrdersView.updateInputTag(subId,pos)
    })
  },
  deleteOrderButton: function() {
    $('.delete-order').click(function(event){
      event.preventDefault();
      subId = $(this).data('subid')
      OrdersView.removeOrderFromBatch(subId)
    })
  },
  confirmOrderButton: function(){
    $('.confirm-order').click(function(event){
      event.preventDefault();
      subId = $(this).data('subid')
      OrdersController.unConfirmOrderButton()
      OrdersView.confirmOrderFromBatch(subId)
    })
  },
  unConfirmOrderButton: function(){
    $('.unconfirm-order').click(function(event){
      event.preventDefault();
      subId = $(this).data('subid')
      OrdersController.confirmOrderButton()
      OrdersView.unConfirmOrderFromBatch(subId)
    })
  },
  saveOrderLoadButton: function() {
    $('.save-order').click(function(event){
      subId = $(this).data('subid')
      OrdersView.showSaveLoader(subId)
    })
  },
  saveOrderButton: function() {
    $(".new_sub_order").on("ajax:success", function(e, data, status, xhr) {
      subId = $(this).data('subid')
      OrdersView.saveSingleOrder(subId)
    }).bind("ajax:error", function(e, xhr, status, error) {
      alert('error')
    })
  },
  sendToShipstationButton: function() {
    $('.send-to-shipstation').click(function(event){
      event.preventDefault();
      orderId = $(this).data('orderid')
      $('.overlay').addClass('overlay-show')
      $('.overlay').addClass('overlay-impt')
      $('.loader').addClass('loader-show')
      $('.loader').addClass('loader-impt')
      $('#ballWrapper').removeClass('ballWrapper')
      OrdersModel.sendToShipstation(orderId)
    })
  }
}


var OrdersModel = {
  displayedPos: {},
  addFirstRecsToPos: function(subId) {
    inputSize = $('div[data-sub="'+subId+'"] > div > div > input').size()
    this.displayedPos[subId] = []
    for (var i = 0; i < inputSize; i++) {
      this.displayedPos[subId].push(i)
    }
  },
  generateKitterRecs: function(subId) {
    path = '/kitter/'+ subId
    $.getJSON(path,function(response) {
    })
  },
  nextRec: function(subId,pos) {
    this.displayedPos[subId][pos] += 1
  },
  prevRec: function(subId,pos) {
    this.displayedPos[subId][pos] -= 1
  },
  checkDupe: function(subId,pos) {
    sku = $($('div[data-sub="'+subId+'"] > div > div > input')[pos]).val()
    path = '/'+subId+'/check-dupe/'+sku.toLowerCase()
    $.getJSON(path, function(response) {
      console.log(response)
        if (response == true) {
          OrdersView.dupedProduct(subId,pos)
        }
        else {
          OrdersView.removeDupedProduct(subId,pos)
        }
      });
  },
  sendToShipstation: function(orderId) {
    path = '/send-to-shipstation'
    $.post(path,{order_id: orderId}).done(function(data) {
      $('.loader').removeClass('loader-show')
      $('#ballWrapper').addClass('ballWrapper')
      OrdersView.displaySysMsg('Sent to Shipstation!')
    }).fail(function(data) {
      $('.loader').removeClass('loader-show')
      $('#ballWrapper').addClass('ballWrapper')
      OrdersView.displaySysMsg('Unable to Send!')
    })

  }
}


var OrdersView = {
  inputFirstRecs: function(subId) {
    inputTags = $('div[data-sub="'+subId+'"] > div > div > input')
    $.each(inputTags, function(index,inputTag) {
      path = '/next-kitter/' + subId + '/' + OrdersModel.displayedPos[subId][index]
      $.getJSON(path, function(response) {
        $(inputTag).val(response.sku)
        OrdersView.prevImg(subId,index)
      });
    })
  },
  showAllLoaders: function(subId) {
    inputTags = $('div[data-sub="'+subId+'"] > div > div > input')
    $.each(inputTags, function(index,inputTag) {
      OrdersView.showLoader(subId,index)
    });
  },
  showLoader: function(subId,pos) {
    imgTag = $($('div[data-sub="'+subId+'"] > div > .preview-image')[pos])
    imgTag.html('<img src=/assets/loader.gif class=loading>')
  },
  showSaveLoader: function(subId) {
    $('div[data-subid='+subId+'].vert-button-tray').hide()
    $('div[data-subid='+subId+'].order-save').show().addClass('success-overlay')
  },
  updateInputTag: function(subId,pos) {
    inputTag = $('div[data-sub="'+subId+'"] > div > div > input')[pos]
    path = '/next-kitter/' + subId + '/' + OrdersModel.displayedPos[subId][pos]
    $.getJSON(path, function(response) {
      $(inputTag).val(response.sku)
        OrdersView.prevImg(subId,pos)
      });
  },
  prevImg: function(subId,pos) {
    sku = $($('div[data-sub="'+subId+'"] > div > div > input')[pos]).val()
    ajaxLink = '/products/' + sku
    $.getJSON(ajaxLink,function(response) {
      imgTag = $($('div[data-sub="'+subId+'"] > div > .preview-image')[pos])
      imgTag.html('<img src='+response['small_pic']+'>')
    },OrdersView.showLoader(subId,pos))
  },
  removeImg: function(subId,pos) {
    imgTag = $($('div[data-sub="'+subId+'"] > div > .preview-image')[pos])
    imgTag.html("<img src='/assets/no-prev.jpg'>")
  },
  removeOrderFromBatch: function(subId) {
    $('tr[data-subid='+subId+']').remove()
  },
  confirmOrderFromBatch: function(subId) {
    $('.editable[data-subid='+subId+']').hide()
    $('.uneditable[data-subid='+subId+']').show()
    $('div[data-sub="'+subId+'"] > div > div > input').hide()
  },
  unConfirmOrderFromBatch: function(subId) {
    $('.editable[data-subid='+subId+']').show()
    $('.uneditable[data-subid='+subId+']').hide()
    $('div[data-sub="'+subId+'"] > div > div > input').show()
  },
  saveSingleOrder: function(subId) {
    $('div[data-subid='+subId+'].order-save>.loading').hide()
    $('div[data-subid='+subId+'].order-save>.order-complete').show()
  },
  dupedProduct: function(subId,pos) {
    $($('div[data-sub="'+subId+'"] > div > .duped')[pos]).show()
  },
  removeDupedProduct: function(subId,pos) {
    $($('div[data-sub="'+subId+'"] > div > .duped')[pos]).hide()
  },
  displaySysMsg: function(msg) {
    $('.sys-msg').empty()
    $('.sys-msg').append('<h2>' + msg + '</h2>')
    $('.sys-msg').addClass('sys-msg-show')
    $('.sys-msg').addClass('sys-msg-impt')
    setTimeout(function() {
      OrdersView.removeSysMsg()
    },2000)
  },
  removeSysMsg: function() {
    $('.sys-msg').removeClass('sys-msg-show')
    setTimeout(function() {
      $('.sys-msg').removeClass('sys-msg-impt')
    },1000)
    $('.overlay').removeClass('overlay-show')
    setTimeout(function() {
      $('.overlay').removeClass('overlay-impt')
    },1000)
  }
}
