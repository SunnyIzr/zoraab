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

$(document).ready(previewProduct())

function previewProduct() {
  $(document).click(alertMe)
}

function alertMe() {
  link = findLink()
  appendImage(link)
}

function findLink() {
  return 'http://cdn.shopify.com/s/files/1/0127/4312/products/' + $('input#item_').val() + '_small.jpeg'
}

function appendImage(link) {
  $('td.preview-image').html('<img src="'+ link + '">')
}

