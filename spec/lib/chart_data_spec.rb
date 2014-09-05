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

  context "generate_data_for_usage_chart" do
    let(:report) { OpenStruct.new(report_dois: [report_dois]) }
    let(:data) { { "month" => "8", "year" => "2014", "html_views" => "138390", "pdf_views" => "2803", "xml_views" => "47", "full-text" => "13", "pdf" => 6 } }
    let(:counter) { { events: [{
      "month" => data["month"],
      "year" => data["year"],
      "pdf_views" => data["pdf_views"],
      "xml_views" => data["xml_views"],
      "html_views" => data["html_views"]
      }]} }
    let(:pmc) { { events: [{
      "month" => data["month"],
      "year" => data["year"],
      "full-text" => data["full-text"],
      "pdf" => data["pdf"]
    }]} }
    let(:html) { data["html_views"].to_i + data["full-text"].to_i }
    let(:pdf) { data["pdf_views"].to_i + data["pdf"].to_i }
    let(:xml) { data["xml_views"].to_i }
    let(:usage_data) { [[0, html, "Month: 0\nHTML Views: #{html}", pdf, "Month: 0\nPDF Views: #{pdf}", xml, "Month: 0\nXML Views: #{xml}"]] }

    context "full report" do
      let(:report_dois) { OpenStruct.new(alm: { counter: counter, pmc: pmc }) }

      it "should generate data" do
        response = subject.generate_data_for_usage_chart(report)
        response.should eq(usage_data)
      end
    end

    context "missing counter source" do
      let(:report_dois) { OpenStruct.new(alm: { pmc: pmc }) }

      it "should generate data" do
        response = subject.generate_data_for_usage_chart(report)
        response.should be_empty
      end
    end

    context "missing counter events" do
      let(:report_dois) { OpenStruct.new(alm: { counter: {}, pmc: pmc }) }

      it "should generate data" do
        response = subject.generate_data_for_usage_chart(report)
        response.should be_empty
      end
    end

    context "missing pmc source" do
      let(:report_dois) { OpenStruct.new(alm: { counter: counter }) }
      let(:html) { data["html_views"].to_i }
      let(:pdf) { data["pdf_views"].to_i }

      it "should generate data" do
        response = subject.generate_data_for_usage_chart(report)
        response.should eq(usage_data)
      end
    end

    context "missing pmc events" do
      let(:report_dois) { OpenStruct.new(alm: { counter: counter, pmc: {} }) }
      let(:html) { data["html_views"].to_i }
      let(:pdf) { data["pdf_views"].to_i }

      it "should generate data" do
        response = subject.generate_data_for_usage_chart(report)
        response.should eq(usage_data)
      end
    end
  end
end
