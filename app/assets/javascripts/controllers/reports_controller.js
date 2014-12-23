AlmReport.ReportsController = Ember.ObjectController.extend({
  single: function () {
    return this.get('items').get('length') == 1;
  }.property('model.items')
});
