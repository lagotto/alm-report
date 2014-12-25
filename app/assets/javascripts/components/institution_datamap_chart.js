AlmReport.InstitutionDatamapChartComponent = Ember.Component.extend({
    tagName: 'div',

    prepareData: function() {
        return _(this.get('items.content')).map(function (i) {
            return i.get('affiliations') ?
                i.get('affiliations').map(function (a) {
                    return a ? {
                            longitude: a.location.lng,
                            latitude: a.location.lat,
                            full: a.full,
                            radius: 10
                        } :
                        undefined
                }) :
                undefined
            })
            .flatten()
            .compact()
            // Group by full institution name and set the radius accordingly
            .groupBy(function (a) { return a.full }).map(function(v, k) {
                var a = v[0];
                a.radius = Math.sqrt(v.length * 20);
                a.papers = v.length;
                return a;
            })
        .value();
    }.property('items'),


    draw: function () {
        var chart = new Datamap({
            scope: 'world',
            fills: {
                defaultFill: '#6b6b6b'
            },
            element: this.$('.chart')[0],
        });

        chart.bubbles(this.get('prepareData'), {
            popupTemplate: function (geo, data) {
                    return ['<div class="hoverinfo">' +  data.full,
                    '<br/>Number of papers: ' +  data.papers +
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
