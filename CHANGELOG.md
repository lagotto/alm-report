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
