AlmReport.BubbleChartComponent = Ember.Component.extend({
  tagName: 'div',
  axes: [
    {key: 'mendeley', display: 'Mendeley'},
    {key: 'scopus', display: 'Scopus'},
    {key: 'nature', display: 'Nature'},
    {key: 'citeulike', display: 'CiteULike'},
    {key: 'pmc', display: 'PMC'}
  ],
  axis: 'mendeley',

  size: function () {
    return this.get('items').content.length
  }.property('items'),

  minDate: function () {
    return _.min(this.get('items').toArray(), function (i) {
      return i.get('published')
    }).get('published').toLocaleString('si').slice(0,10)
  }.property('items'),

  maxDate: function () {
    return _.max(this.get('items').toArray(), function (i) {
      return i.get('published')
    }).get('published').toLocaleString('si').slice(0,10)
  }.property('items'),

  axisChanged: function() {
    this.update();
  }.observes('axis'),

  prepareData: function(data, column) {
    return data.map( function (d) {
      function monthDiff(d1, d2) {
        months = (d2.getFullYear() - d1.getFullYear()) * 12;
        months -= d1.getMonth() + 1;
        months += d2.getMonth();
        return months <= 0 ? 0 : months;
      }

      var months = monthDiff(d.get('published'), new Date());

      var result = {
        months: months,
        views: d.get('viewed'),
        url: d.get('canonical_url'),
        journal: d.get('journal'),
        title: d.get('title')
      }

      result[column] = _.find(d.get('sources'), function (source) {
        return source.name === column
      }).metrics.total;
      return result;
    });
  },

  update: function () {
    var preparedData = this.get('prepareData')(this.get('items'), this.get('axis'));

    // TODO:
    //   'PLOS ONE': {color: 'fda328'},                    // Orange
    //   'PLOS Biology': {color: '1ebd21'},                // Green
    //   'PLOS Computational Biology': {color: '1ebd21'},  // Green
    //   'PLOS Genetics': {color: '1ebd21'},                // Green
    //   'default': {color: 'b526fb'}                      // Purple

    this.get('chart').update({
      width: this.get('width'),
      height: this.get('height'),
      x: "months",
      y: "views",
      radius: this.get('axis'),
      category: "journal",
      tooltip: "title"
    }, preparedData);
  },

  draw: function () {
    var preparedData = this.get('prepareData')(this.get('items'), this.get('axis'));

    var chart = new BubbleChart;

    chart.create(this.$('.chart')[0], {
      width: this.get('width'),
      height: this.get('height'),
      x: "months",
      y: "views",
      radius: this.get('axis'),
      category: "journal",
      tooltip: "title"
    }, preparedData);

    this.set('chart', chart);
  },

  didInsertElement: function(){
    this.draw();
  }
});
