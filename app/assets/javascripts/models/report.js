AlmReport.Report = DS.Model.extend({
  total: DS.attr('number'),
  total_pages: DS.attr('number'),
  page: DS.attr('number'),
  error: DS.attr('string'),
  items: DS.hasMany('item')
});

AlmReport.ReportSerializer = DS.RESTSerializer.extend(
  DS.EmbeddedRecordsMixin, {
  attrs: {
    items: { embedded: 'always' }
  }
});
