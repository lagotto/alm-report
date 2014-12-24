// For more information see: http://emberjs.com/guides/routing/

AlmReport.Router.map(function() {
  this.resource('reports', { path: '/visualizations/:report_id'});
});

AlmReport.Router.reopen({
  location: 'auto',
  rootURL: '/reports/'
});

