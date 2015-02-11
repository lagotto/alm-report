# 2.2.1

ALM Reports 2.2.1 was released on February 11, 2015.

This release contains several small bug fixes for precompiling javascripts, minor CSS changes, and some other minor tweaks.

# 2.2.0

ALM Reports 2.2.0 was released on January 7th, 2014.

In this release we replaced the previous [Google Charts based visualizations with custom D3 visualizations](https://github.com/articlemetrics/alm-report/pull/91), hosted in an [Ember.js](http://emberjs.com/) application. This release introduces our bubble chart (https://github.com/articlemetrics/bubble), line chart (https://github.com/articlemetrics/line) and sunburst (https://github.com/articlemetrics/sunburst) visualizations. For map-based visualizations, we used the [datamaps](https://github.com/markmarkoh/datamaps) library.

We've also added filtering/faceting support for both PLOS and CrossRef search backends (see #121 and #126) . Because of this feature and visualizations, a restructuring of the layout was necessary and the application now uses a framework for its widened layout (http://getskeleton.com/).

Additionally we've started using the version 5 ALM API (http://alm.plos.org/docs/api) for visualizations data.

# 2.1.0

ALM Reports 2.1.0 was released on October 18, 2014.

This release contains a major refactor of the search functionality, which now supports searching through CrossRef’s API, as well as PLOS’s API. Additionally, it is now possible to use any ALM v3 API (e.g. http://det.labs.crossref.org or http://alm.plos.org) as a metrics source. For more information, check out [Configuring ALM and search backends](https://github.com/articlemetrics/alm-report/blob/master/docs/development.md#configuring-alm-and-search-backends)

Besides these two major changes, several issues were addressed:

- "Select all articles" functionality (#58, #84)
- Incorrect added articles counter (#65)
- Preview page display issues (#66)
- Sorting functionality (#59)
- Several small issues (#56, #60, #64, #67, #80, #81)

# 2.0.2

ALM Reports 2.0.2 was released on October 6, 2014.

This is a bugfix release that addresses an issue (issue #50) whereby publication date filtering was not taken into account.

# 2.0.1

ALM Reports 2.0.1 was released on September 20, 2014.

This release contains some refactoring in terms of how we structure and build Solr requests and how we internally handle adding articles to a report. Besides these two changes, this is mostly a bugfix release, containing the following fixes:

- A fix for errors regarding Solr's sort order #38
- A guard for building Solr queries with nil parameters #41
- Properly handling DOI limit #36
- Properly handling expired sessions and storing DOIs in session (#34, #37)

# 2.0.0

ALM Reports 2.0.0 was released on September 6, 2014. For this release we:

- Introduced a simple way to change color schemes for the entire application using SCSS variables
- Made development setup straightforward using Vagrant and Chef
- Added basic integration tests
- Fixed two issues with rendering visualizations (#13, #24)
- Licensed software using the MIT license
- Updated documentation
- Various minor layout and CSS fixes
