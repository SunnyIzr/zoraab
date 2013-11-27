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
  $('input').keyup(function() {
    previewProduct($(this).val(),this.attr('data'))
    });
    fillKitter();
    nextLink();
    shopifySync();
  });

var nextProduct = {
  pos: 0,
  countUp: function() {
    return this.pos += 1
  }
}

function showAllPreviews() {
  ary = $('tr')
  $.each(ary,function(key,value){
    previewProduct($(value).find('input').val(),key-1)
  })
}

function previewProduct(sku,index) {
  ajaxLink = '/products/' + sku
  $.getJSON(ajaxLink, function(response) {
    appendImage(response['small_pic'],index)
  }, removeImage(index))
}

function appendImage(link,index) {
  $('.preview-image-'+index).html('<img src="'+ link + '">')
}

function removeImage(index) {
  $('.preview-image-'+index).html('')
}

function fillKitter() {
  $('.ungen').click(function(event) {
    event.preventDefault();
    $('.ungen').html('Next');
    $('.next-link').show();
    ary = $('input.selection')
    $.each(ary,function(key,value) {
      fillWithNextProd(value,key,nextProduct.pos);
      nextProduct.countUp();
    })
  })
}

function fillWithNextProd(inputTag,index,pos) {
  subId = window.location.href.split('/')[4]
  $.getJSON('/kitter/'+subId, function(response) {
    $(inputTag).val(response[pos]['sku']);
    previewProduct(response[pos]['sku'],index)
  })
}

function nextLink() {
  $('.next-link').click(function(event) {
    event.preventDefault();
    index = $(this).attr('data')
    fillWithNextProd($('input.selection')[index],index,nextProduct.pos);
    nextProduct.countUp();
  })
}

function shopifySync() {
  $('a#shopify_sync').click(function(event) {
    event.preventDefault();
    $('.overlay').show();
    $('#loader').show();
    window.location.href = '/sync'

  })
}
