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
                        if(next.citations) {
                           next.citations = next.citations + d.get('cited');
                        } else {
                           next.citations = d.get('cited');
                        }

                    } else if (j == s.length - 1) {
                        next = {
                            name: e,
                            views: d.get('viewed'),
                            citations: d.get('cited')
                        }
                    } else {
                        next = {
                            name: e,
                            children: [],
                            citations: d.get('cited')
                        }
                    }

                    if(next !== node) {
                        if(current == undefined) current = [];
                        current.push(next)
                    }

                    current = next.children
                })
            });
        })

        tree.citations = _.reduce(tree.children, function(sum, subject) {
            return sum + subject.citations;
        }, 0);

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
