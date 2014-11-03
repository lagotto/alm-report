AlmReport.BubbleChartComponent = Ember.Component.extend({
  tagName: 'div',
  axes: [ 'mendeley', 'scopus', 'nature', 'citeulike', 'pmc' ],
  axis: 'mendeley',

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

      var date = new (Function.prototype.bind.apply(
          Date, [null].concat(d.get('issued')['date-parts'])
      ))

      var months = monthDiff(d.get('published'), new Date());

      var result = {
          months: months,
          views: d.get('viewed'),
          tooltip: d.get('title'),
          url: d.get('canonical_url'),
          journal: d.get('journal')
      }

      result[column] = _.find(d.get('sources'), function (source) {
        return source.name === column
      }).metrics.total;
      return result;
    });
  },

  update: function () {
    var preparedData = this.get('prepareData')(this.get('items'), this.get('axis'));

    this.get('chart').update({
      width: this.get('width'),
      height: this.get('height'),
      x: "months",
      y: "views",
      radius: this.get('axis'),
      category: "journal"
    }, preparedData);
  },

  draw: function () {
    var preparedData = this.get('prepareData')(this.get('items'), this.get('axis'));

    var chart = new BubbleChart;

    chart = chart.create(this.element, {
      width: this.get('width'),
      height: this.get('height'),
      x: "months",
      y: "views",
      radius: this.get('axis'),
      category: "journal"
    }, preparedData);

    this.set('chart', chart);
  },

  didInsertElement: function(){
    this.draw();
  }
});
