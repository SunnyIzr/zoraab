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
  $(document).click(showAllPreviews)
  })

function showAllPreviews() {
  ary = $('tr')
  $.each(ary,function(key,value){
    previewProduct($(value).find('input'),key-1)
  })
}

function previewProduct(element, index) {
    showPreviewImage(element.val(),index)
}

function showPreviewImage(sku,index) {
  ajaxLink = '/products/' + sku
  $.getJSON(ajaxLink, function(response) {
    appendImage(response['small_pic'],index)
  })
}

function appendImage(link,index) {
  $('td.preview-image-'+index).html('<img src="'+ link + '">')
}


