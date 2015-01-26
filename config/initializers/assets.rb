# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(
  charts.js print.css html5shiv.js application.plos.css alm_report.js
  lodash/dist/lodash.js d3-tip/index.js bubble/app/scripts/bubble_chart.js
  sunburst/app/scripts/sunburst_chart.js line/app/scripts/line_chart.js datamaps/dist/datamaps.world.js
)

Rails.application.config.assets.paths << Rails.root.join("vendor","assets","bower_components")
