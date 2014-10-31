AlmReport.Report = DS.Model.extend({
  total: DS.attr('number'),
  page: DS.attr('number'),
  items: DS.hasMany('item')
});
