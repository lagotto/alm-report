AlmReport.BubbleChartComponent = Ember.Component.extend({
  tagName: 'div',
  axes: [
    {key: undefined, display: 'No source selected'},
    {key: 'citeulike', display: 'CiteULike bookmarks'},
    {key: 'crossref', display: 'CrossRef citations'},
    {key: 'f1000', display: 'F1000Prime recommendations'},
    {key: 'facebook', display: 'Facebook shares'},
    {key: 'figshare', display: 'Figshare usage'},
    {key: 'mendeley', display: 'Mendeley bookmarks'},
    {key: 'pmceurope', display: 'PMC Europe citations'},
    {key: 'pmceuropedata', display: 'PMC Europe database citations'},
    {key: 'scienceseeker', display: 'ScienceSeeker bookmarks'},
    {key: 'scopus', display: 'Scopus citations'},
    {key: 'reddit', display: 'Reddit mentions'},
    {key: 'researchblogging', display: 'ResearchBlogging mentions'},
    {key: 'twitter', display: 'Twitter shares'},
    {key: 'wos', display: 'Web of Science citations'},
    {key: 'wordpress', display: 'WordPress.com mentions'},
    {key: 'wikipedia', display: 'Wikipedia mentions'},
  ],

  axis: function () {
    var initial = this.get('axes').find(function (a) {
      return a.key == 'scopus'
    })
    if(initial) {
      return initial
    } else {
      return this.get('axes')[0]
    }
  }.property('axes'),

  axisChanged: function() {
    if(this.get('chart')) { this.update() }
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

      if(column) {
        result[column] = _.find(d.get('sources'), function (source) {
          return source.name === column
        }).metrics.total;
      }

      return result;
    });
  },

  update: function () {
    var preparedData = this.get('prepareData')(
      this.get('items'),
      this.get('axis').key
    );

    this.get('chart').update({
      width: this.get('width'),
      height: this.get('height'),
      x: "months",
      y: "views",
      radius: this.get('axis').key,
      radiusLabel: this.get('axis').display,
      category: "journal",
      tooltip: "title"
    }, preparedData);
  },

  colors: function () {
    if(true) {     // TODO: specify colors only if PLOS:
      return {
          'PLOS ONE': '#fda328',                        // Orange
          'PLOS Biology': '#1ebd21',                    // Green
          'PLOS Computational Biology': '#1ebd21',      // Green
          'PLOS Genetics': '#1ebd21',                   // Green
          'PLOS Medicine': '#891fb1',                   // Purple
          'PLOS Pathogens': '#891fb1',                  // Purple
          'PLOS Neglected Tropical Diseases': '#891fb1',// Purple
          'default': '#b526fb'                          // Purple
      }
    }
  },

  removeEmptySources: function () {
    var emptySources = _.intersection.apply(this, this.get('items').map(
      function (d) {
        return _(d.get('sources')).map(function(s) {
          if(!s.metrics || s.metrics.total == 0) {
            return s.name
          }
        }).compact().value();
    }));

    this.set('axes', _.filter(this.get('axes'), function (selection) {
      return emptySources.indexOf(selection.key) == -1;
    }));
  },

  draw: function () {
    this.get('removeEmptySources').bind(this)();

    var preparedData = this.get('prepareData')(
      this.get('items'),
      this.get('axis').key
    );

    var chart = new BubbleChart;

    chart.create(this.$('.chart')[0], {
      width: this.get('width'),
      height: this.get('height'),
      x: "months",
      xLabel: "Months",
      y: "views",
      yLabel: "Total Usage",
      radius: this.get('axis').key,
      radiusLabel: this.get('axis').display,
      category: "journal",
      tooltip: "title",
      colors: this.get('colors')()
    }, preparedData);

    this.set('chart', chart);
  },

  didInsertElement: function(){
    this.draw();
  }
});
