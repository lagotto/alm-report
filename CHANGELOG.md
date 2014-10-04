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
