AlmReport.LineChartComponent = Ember.Component.extend({
    tagName: 'div',

    item: function () {
        return this.get('items.content')[0].get('data');
    }.property('items'),

    data: function () {
        return _(this.get('item').sources).find(function (d) {
            return d.name == "counter";
        }).events
    }.property('item'),

    html: function () {
        return _(this.get('data')).map(function (d) {
            var date = new Date(d.year, d.month)
            return { time: date, views: +d.html_views }
        }).value()
    }.property('data'),

    pdf: function () {
        return _(this.get('data')).map(function (d) {
            var date = new Date(d.year, d.month)
            return { time: date, views: +d.pdf_views }
        }).value()
    }.property('data'),

    xml: function () {
        return _(this.get('data')).map(function (d) {
            var date = new Date(d.year, d.month)
            return { time: date, views: +d.xml_views }
        }).value()
    }.property('data'),

    prepareData: function () {
        return {
            html: this.get('html'),
            pdf: this.get('pdf'),
            xml: this.get('xml'),
            url: this.get('item').canonical_url,
            journal: this.get('item').journal,
            title: this.get('item').title
        }
    }.property('item'),

    draw: function () {
        var preparedData = this.get('prepareData');
        var chart = new LineChart;

        chart.create(this.$('.chart')[0], {
            width: this.get('width'),
            height: this.get('height'),
            x: "time",
            y: "views",
            lines: ["html", "pdf", "xml"],
            category: "journal",
            tooltip: "title",
            colors: ['#fda328',
                '#1447f2',
                '#891fb1']
        }, preparedData);

        this.set('chart', chart);
    },

    update: function () {
        this.get('chart').update({
            width: 1000,
            height: 600,
            x: "time",
            y: "views",
            lines: ["html", "pdf"],
            category: "journal",
            tooltip: "title"
        }, preparedData);
    },

    didInsertElement: function(){
        this.draw();
    }
});
