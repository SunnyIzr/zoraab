var OrdersController = {
  init: function() {
    this.genButton()
    this.inputKeyUp()
    this.nextProductButton()
    this.prevProductButton()
  },
  genButton: function() {
    $('#generate-button').click(function(event){
      event.preventDefault();
      subId = $(this).attr('data-sub-id')
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
  }
}


var OrdersModel = {
  displayedPos: {},
  //displayedPos holds what is currently being shown in hash form ex: {subId, [ary of Pos Ids]}
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
    },OrdersView.removeImg(subId,pos))
  },
  removeImg: function(subId,pos) {
    imgTag = $($('div[data-sub="'+subId+'"] > div > .preview-image')[pos])
    imgTag.html("<img src='/assets/no-prev.jpg'>")
  }
}
