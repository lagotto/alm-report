AlmReport.Item = DS.Model.extend({
  doi: DS.attr('string'),
  title: DS.attr('string'),
  journal: DS.attr('string'),
  publisher_id: DS.attr('number'),
  issued: DS.attr(),
  published: function () {
    var parts = this.get('issued')['date-parts'][0]
    if(parts[1]) {
      parts[1] = parts[1] - 1;
    }
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
  wos: DS.attr('string'),
  scp: DS.attr('string'),
  update_date: DS.attr('date'),
  viewed: DS.attr('number'),
  saved: DS.attr('number'),
  discussed: DS.attr('number'),
  cited: DS.attr('number'),
  subjects: DS.attr(),
  sources: DS.attr(),
  affiliations: DS.attr(),
  events: DS.attr()
});
