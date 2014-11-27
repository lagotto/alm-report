AlmReport.DatamapChartComponent = Ember.Component.extend({
    tagName: 'div',

    prepareData: function () {
        return _(this.get('items.content')).map(function (i) {
            return i.get('affiliations') ?
                i.get('affiliations').map(function (a) {
                    return a ? {
                            longitude: a.location.lng,
                            latitude: a.location.lat,

                            full: a.full,
                            radius: 3
                        } :
                        undefined
                }) :
                undefined
            })
            .flatten()
            .compact()
            // Group by full instititun name and set the radius accordingly
            .groupBy(function (a) { return a.full }).map(function(v, k) {
                var a = v[0];
                a.radius = v.length;
                return a;
            })
            .value()

    }.property('items'),

    draw: function () {
        var preparedData = this.get('prepareData');

        var chart = new Datamap({scope: 'world', element: this.$('.chart')[0]});

        chart.bubbles(preparedData, {
            popupTemplate: function (geo, data) {
                    return ['<div class="hoverinfo">' +  data.full,
                    '<br/>Number of authors: ' +  30 + ' ',
                    '<br/>Number of papers: ' +  20 + '',
                    '</div>'].join('');
                }
        });

        this.set('chart', chart);
    },

    update: function () {
    },

    didInsertElement: function(){
        this.draw();
    }
});
