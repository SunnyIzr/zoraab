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
    $.post( '/subs-with-trans', {cid: cId}).done(function(data) {
      myData = data
      console.log(data)
    })
  }
}
var DashboardView = {

}
