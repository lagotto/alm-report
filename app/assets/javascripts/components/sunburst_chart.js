AlmReport.SunburstChartComponent = Ember.Component.extend({
    tagName: 'div',

    // Converts data
    prepareData: function () {
        var tree = {name: 'all', children: []};
        this.get('items').forEach(function(d) {
            d.get('subjects').forEach(function (s,i) {
                var current = tree.children;
                s.forEach(function (e,j) {
                    var node = _.find(current, function(n) {
                        return n.name == e;
                    });

                    var next;

                    if(node) {
                        next = node
                    } else if (j == s.length - 1) {
                        next = { name: e, views: d.get('viewed') }
                    } else {
                        next = { name: e, children: []}
                    }

                    if(next !== node) {
                        if(current == undefined) current = [];
                        current.push(next)
                    }

                    current = next.children
                })
            });
        })

        return tree;
    }.property('items'),

    draw: function () {
        var preparedData = this.get('prepareData');

        var chart = new SunburstChart;
        chart.create(this.$('.chart')[0], {
            width: this.get('width'),
            height: this.get('height'),
            radius: this.get('height') / 2 - 20,
            breadcrumb: {
                // Breadcrumb dimensions: width, height, spacing, width of tip/tail.
                width: 195,
                height: 30,
                spacing: 3,
                tip: 10
            }
        }, preparedData)
        this.set('chart', chart);
    },

    didInsertElement: function(){
        this.draw();
    }
});
