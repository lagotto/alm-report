require 'spec_helper'
require 'chart_data'

describe ChartData do
  subject { ChartData }

  let(:report) { [{ "update_date" => "2013-06-09T03:49:14Z", "total" => 528 },
                  { "update_date" => "2013-05-08T18:15:07Z", "total" => 508 },
                  { "update_date" => "2013-04-06T23:28:36Z", "total" => 492 }] }

  context "process_history_data" do
    it "should process data" do
      response = subject.process_history_data(report)
      response.should eq("2013-4"=>492, "2013-5"=>508, "2013-6"=>528)
    end

    it "should handle nil" do
      report = nil
      response = subject.process_history_data(report)
      response.should be_empty
    end
  end
end
