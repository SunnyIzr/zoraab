var UpcomingSubsController = {
  init: function() {
  },
}

var UpcomingSubsModel = {
  getUpcomingSubs: function() {
    path = '/render-upcoming-subs/'
    $.get(path, function(data) {
      UpcomingSubsView.showUpcomingSubs(data)
    });
  }
}
var UpcomingSubsView = {
  showUpcomingSubs: function(data) {
    $('#upcoming-subs').html(data)
  }


}
