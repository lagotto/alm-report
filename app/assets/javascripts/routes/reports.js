AlmReport.ReportsRoute = Ember.Route.extend({
  setupController: function(controller, report) {
    controller.set('model', report);
  }
});
