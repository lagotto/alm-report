require "date"
require "test_helper"

class SolrRequestTest < ActiveSupport::TestCase

  test "parse_date_range_test" do
    start_date, end_date = SolrRequest.parse_date_range("-1", nil, nil)
    assert_nil(start_date)
    assert_nil(end_date)
    assert_nil(SolrRequest.build_date_range(nil, nil))

    start_date, end_date = SolrRequest.parse_date_range("0", "09-15-2012", "02-28-2013")
    assert_equal("[2012-09-15T00:00:00Z TO 2013-02-28T23:59:59Z]",
        SolrRequest.build_date_range(start_date, end_date))

    Timecop.travel(Date.strptime("2013-03-01", "%Y-%m-%d").to_time)
    start_date, end_date = SolrRequest.parse_date_range("30", nil, nil)
    assert_equal("[2013-01-30T00:00:00Z TO 2013-03-01T00:00:00Z]",
        SolrRequest.build_date_range(start_date, end_date))
    Timecop.return

    # TODO: test end day before start day and other error cases.
  end
end
