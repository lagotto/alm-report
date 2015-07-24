function haveDataToDrawViz() {
  return true
}

function drawVizForOne() {
  return false;
}

function prepareData(data, column) {
  return _.map(data["data"], function (d) {
    function monthDiff(d1, d2) {
        months = (d2.getFullYear() - d1.getFullYear()) * 12;
        months -= d1.getMonth() + 1;
        months += d2.getMonth();
        return months <= 0 ? 0 : months;
    }

    var date = new (Function.prototype.bind.apply(
        Date, [null].concat(d["issued"]["date-parts"])
    ))

    var months = monthDiff(date, new Date())

    var result = {
        months: months,
        views: d["viewed"],
        tooltip: d["title"],
        url: d["canonical_url"],
        journal: d["journal"]
    }
    result[column] = d[column];
    return result;
  });
}

$.ajax({
  url: "/api/report_alm?id=84",
  success: function(data) {
    var preparedData = prepareData(data, "cited")

    // And then configure the chart.
    BubbleChart.create($("#citations")[0], {
        width: 500,
        height: 400,
        x: "months",
        y: "views",
        radius: "cited",
        category: "journal"
    }, preparedData);
  }
});

$.ajax({
  url: "/api/report_alm?id=84",
  success: function(data) {
    var preparedData = prepareData(data, "saved")
    // And then configure the chart.
    BubbleChart.create($("#saved")[0], {
        width: 500,
        height: 400,
        x: "months",
        y: "views",
        radius: "saved",
        category: "journal"
    }, preparedData);
  }
});


function getWorkUsageCitationsAge() {
    // return #{{ @work_usage_citations_age_data.to_json }};
}

function getWorkUsageMendeleyAge() {
    // return #{{ @work_usage_mendeley_age_data.to_json }};
}

function getWorkUsageCitationSubjectArea() {
    // return #{{ @work_usage_citation_subject_area_data.to_json }};
}

function getWorkLocation() {
    // return #{{ @work_locations_data.to_json }};
}
