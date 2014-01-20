// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

$(function(){ $(document).foundation(); });

$(document).ready(function() {
    shopifySync();
    OrdersController.init()

  });


function shopifySync() {
  $('a#shopify_sync').click(function(event) {
    event.preventDefault();
    $('.overlay').show();
    $('#loader').show();
    window.location.href = '/sync'

  })
}

var OrdersController = {
  init: function() {
    this.genButton()
  },

  genButton: function() {
    $('#generate-button').click(function(event){
      event.preventDefault();
      subId = $(this).attr('data-sub-id')
      OrdersModel.generateKitterRecs(subId)
      OrdersModel.addFirstRecsToPos(subId)
      OrdersView.inputFirstRecs(subId)
      $('.next-arrow').show();

    })
  }

}

var OrdersModel = {

  displayedPos: {}
  //this holds what is currently being shown in hash form ex: {subId, [ary of Pos Ids]}

  ,

  addFirstRecsToPos: function(subId) {
    inputSize = $('div[data-sub="'+subId+'"] > div > div > input').size()
    nextPos = -1

    this.displayedPos[subId] = []

    for (var i = 0; i < inputSize; i++) {
      this.displayedPos[subId].push(i)
    }
  },

  generateKitterRecs: function(subId) {
    path = '/kitter/'+ subId
    $.getJSON(path,function(response) {
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

  prevImg: function(subId,pos) {
    sku = $($('div[data-sub="'+subId+'"] > div > div > input')[pos]).val()
    ajaxLink = '/products/' + sku

    $.getJSON(ajaxLink,function(response) {
      imgTag = $($('div[data-sub="'+subId+'"] > div > .preview-image')[pos])
      imgTag.html('<img src='+response['small_pic']+'>')
    })
  }
}


//constructs new order objects for each order on the page
// var NewOrdersController = {
//   init: function() {
//     $.each(this.orderSubNumbers(),function(key,value) {
//       new Order (value)
//     })
//     EventsController.genButtonListener();
//   },
//   orderSubNumbers: function() {
//     subNumbers = []
//     $.each ($('[data-sub]'), function(key,value) {
//       subNumbers.push($(value).attr('data-sub'))
//     })
//     return subNumbers
//   }
// // }



// var EventsController = {
//   keyUpListener: function(itemObj){
//     $(itemObj.inputTag()).keyup(function() {
//       itemObj.previewImage()
//     })
//   },

//   genButtonListener: function() {
//     $('#generate-button').click(function(event){
//       event.preventDefault();
//       order = new Order($(this).attr('data-sub-id'))
//       order.fillSuggestions();
//       $('.next-arrow').show();
//       nextButton();

//     })
//   },

//   nextButton: function() {

//   },
// //same as itemObj.previewImage() but wasnt working since its an ajax call within an ajax call
//   fillNextSuggestion: function(itemObj,pos) {
//     path = '/kitter/'+itemObj.subId
//     $.getJSON(path,function(response) {
//       sku = response[pos]['sku']
//       $(itemObj.inputTag()).val(sku);
//       $.getJSON('/products/'+sku,function(response){
//         $(itemObj.imageTag()).html('<img src='+response['small_pic']+'>')
//       })
//     })
//   }
// }

// var itemPrototype = {
//   indexItem: null,

//   itemTag: null,

//   imageTag: function() {
//     return $(this.itemTag).find('.preview-image-'+this.indexItem)
//   },

//   inputTag: function() {
//     return $(this.itemTag).find('input')
//   },

//   subId: null,

//   inputSku: function() {
//      return $( $(this.itemTag).find('input')).val()
//   },

//   previewImgLink: function(){
//     ajaxLink = '/products/' + this.inputSku()
//     itemObject = this
//     imageTag = $('.preview-image-'+this.indexItem)
//     $.getJSON(ajaxLink,function(response) {
//       return response['small_pic']
//     })
//   },

//   previewImage: function() {
//     ajaxLink = '/products/' + this.inputSku()
//     itemObject = this
//     imageTag = $('.preview-image-'+this.indexItem)
//     $.getJSON(ajaxLink,function(response) {
//       imageTag.html('<img src='+response['small_pic']+'>')
//     },itemObject.removeImage())
//   },

//   removeImage: function() {
//     $(this.imageTag()).html("")
//   }
// }


// var orderPrototype = {
//   init: function() {
//     this.itemListInputs();
//   },

//   subId: null,

//   nextPos: 105,

//   countUp: function() {
//     this.nextPos += 1
//   },

//   orderElement: function() {
//     return $('[data-sub='+this.subId+']')
//   },

//   itemListInputs: function() {
//     var inputs = [];
//     subId = this.subId
//     $.each (this.orderElement().find('[data-item]'), function(key,value) {
//       newObj = new Item (key,value,subId)
//       EventsController.keyUpListener(newObj)
//       inputs.push(newObj)
//     })
//     return inputs
//   },

//   fillSuggestions: function() {
//     orderObj = this
//     pos = this.nextPos
//     $.each(orderObj.itemListInputs(), function(key,value) {
//       EventsController.fillNextSuggestion(value,orderObj.nextPos)
//       orderObj.countUp();

//     })
//   },
//   previewAllImages: function() {
//     $.each(this.itemListInputs(),function(key,value) {
//       value.previewImage();
//     })
//   }
// }


// function Item (indexItem,itemTag,subId) {
//   this.indexItem = indexItem
//   this.itemTag = itemTag
//   this.subId = subId
// }

// function Order (subId) {
//   this.subId = subId
//   this.init()

// }

// Item.prototype = itemPrototype

// Order.prototype = orderPrototype;
