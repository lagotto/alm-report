AlmReport.ReportsController = Ember.ObjectController.extend({
  single: function () {
    return this.get('items').get('length') == 1;
  }.property('model.items'),

  minDate: function () {
    return _.min(this.get('items').toArray(), function (i) {
      return i.get('published')
    }).get('published').toLocaleString('si').slice(0,10)
  }.property('model.items'),

  maxDate: function () {
    return _.max(this.get('items').toArray(), function (i) {
      return i.get('published')
    }).get('published').toLocaleString('si').slice(0,10)
  }.property('model.items'),

});
