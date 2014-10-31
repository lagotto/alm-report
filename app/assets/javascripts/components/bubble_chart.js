AlmReport.BubbleChartComponent = Ember.Component.extend({
  tagName: 'svg',

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

      var months = monthDiff(date, new Date());

      var result = {
          months: months,
          views: d.get('viewed'),
          tooltip: d.get('title'),
          url: d.get('canonical_url'),
          journal: d.get('journal')
      }

      result[column] = d.get(column);
      return result;
    });
  },

  draw: function(){
    var preparedData = this.get('prepareData')(this.get('items'), 'cited');

    // And then configure the chart.
    BubbleChart.create(this.element, {
      width: 500,
      height: 400,
      x: "months",
      y: "views",
      radius: "cited",
      category: "journal"
    }, preparedData);
  },

  didInsertElement: function(){
    this.draw();
  }
});
