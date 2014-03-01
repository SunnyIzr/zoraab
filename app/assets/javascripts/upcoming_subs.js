var UpcomingSubsController = {
  init: function() {

  },
}

var UpcomingSubsModel = {
  completedRequest: false,
  getUpcomingSubs: function() {
    path = '/render-upcoming-subs/'
    $.get(path, function(data) {
      UpcomingSubsView.showUpcomingSubs(data)
      UpcomingSubsModel.checkRequestComplete(data)
    });
  },
  checkRequestComplete: function(data) {
    if ($.isEmptyObject(data) == false) {
      UpcomingSubsModel.completedRequest = true
    }
  }

}
var UpcomingSubsView = {
  showUpcomingSubs: function(data) {
    $('#upcoming-subs').html(data)
  }


}
