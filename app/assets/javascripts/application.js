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
  });


function shopifySync() {
  $('a#shopify_sync').click(function(event) {
    event.preventDefault();
    $('.overlay').show();
    $('#loader').show();
    window.location.href = '/sync'

  })
}

var EventsController = {
  keyUpListener: function(itemObj){
    $(itemObj.inputTag()).keyup(function() {
      itemObj.previewImage()
    })
  }
}

var itemPrototype = {
  indexItem: null,
  itemTag: null,
  imageTag: function() {
    return $(this.itemTag).find('.preview-image')
  },
  inputTag: function() {
    return $(this.itemTag).find('input')
  },
  subId: null,
  inputSku: function() {
     return $( $(this.itemTag).find('input')).val()
  },
  previewImage: function() {
    ajaxLink = '/products/' + this.inputSku()
    itemObject = this
    imageTag = $(this.imageTag())
    $.getJSON(ajaxLink,function(response) {
      imageTag.html('<img src='+response['small_pic']+'>')
    },itemObject.removeImage())
  },
  removeImage: function() {
    $(this.imageTag()).html("")
  }
}

var orderPrototype = {
  init: function() {
    this.itemListInputs();
  },
  subId: null,
  orderElement: function() {
    return $('[data-sub='+this.subId+']')
  },
  itemListInputs: function() {
    var inputs = [];
    $.each (this.orderElement().find('[data-item]'), function(key,value) {
      newObj = new Item (key,value,this.subId)
      EventsController.keyUpListener(newObj)
      inputs.push(newObj)
    })
    return inputs
  }
}

function Item (indexItem,itemTag,subId) {
  this.indexItem = indexItem
  this.itemTag = itemTag
  this.subId = subId
}

function Order (subId) {
  this.subId = subId
  this.init()

}

Item.prototype = itemPrototype

Order.prototype = orderPrototype;
