AlmReport.Item = DS.Model.extend({
  doi: DS.attr('string'),
  title: DS.attr('string'),
  journal: DS.attr('string'),
  issued: DS.attr(),
  published: function () {
    var parts = this.get('issued')['date-parts']
    return new Date(
      parts[0],
      parts[1],
      parts[2]
    )
  }.property('issued'),
  canonical_url: DS.attr('string'),
  pmid: DS.attr('string'),
  pmcid: DS.attr('string'),
  mendeley_uuid: DS.attr('string'),
  viewed: DS.attr('number'),
  saved: DS.attr('number'),
  discussed: DS.attr('number'),
  cited: DS.attr('number'),
  subjects: DS.attr(),
  sources: DS.attr()
});
