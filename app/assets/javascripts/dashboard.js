var DashboardController = {
  init: function() {
    this.newSignupBtn()
  },
  newSignupBtn: function() {
    $('.new-sub-signup').click(function(event){
      event.preventDefault();
      cId = $(this).attr('data-cid')
      DashboardModel.createNewSub(cId);
    })
  }
}

var DashboardModel = {
  createNewSub: function(cId){
    $.post( '/subs', {cid: cId}).done(function(data) {
      window.location='/new-sub-order/'+cId
    })
  }
}
var DashboardView = {

}
