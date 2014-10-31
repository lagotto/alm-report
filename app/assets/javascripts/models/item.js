AlmReport.Item = DS.Model.extend({
  doi: DS.attr('string'),
  title: DS.attr('string'),
  journal: DS.attr('string'),
  issued: DS.attr(),
  published: function () {
    return new Date(this.get('issued')['date-parts'])
  }.property('issued'),
  canonical_url: DS.attr('string'),
  pmid: DS.attr('string'),
  pmcid: DS.attr('string'),
  mendeley_uuid: DS.attr('string'),
  viewed: DS.attr('number'),
  saved: DS.attr('number'),
  discussed: DS.attr('number'),
  cited: DS.attr('number')
});
