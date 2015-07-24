require 'rails_helper'

describe Alm do

  context "get ALM Data for works" do

    it "get ALM data for works" do
      report = Report.new
      report.save

      dois = [
        "10.1371/journal.pone.0064652",
        "10.1371/journal.pmed.0020124"
      ]

      report.add_all_dois(dois)

      params = {}
      params[:ids] = dois.sort.join(",")

      url = Alm.get_alm_url(params)

      body = File.read("#{fixture_path}alm_good_response.json")

      stub_request(:get, url).to_return(:body => body, :status => 200)

      data = Alm.get_data_for_works(report.report_dois)

      data.size.should eq(2)

      data['10.1371/journal.pone.0064652'][:plos_html].should eq(308)
      data['10.1371/journal.pone.0064652'][:plos_pdf].should eq(4)
      data['10.1371/journal.pone.0064652'][:plos_xml].should eq(7)
      data['10.1371/journal.pone.0064652'][:plos_total].should eq(319)

      data['10.1371/journal.pone.0064652'][:pmc_views].should eq(0)
      data['10.1371/journal.pone.0064652'][:pmc_pdf].should eq(1)
      data['10.1371/journal.pone.0064652'][:pmc_total].should eq(1)

      data['10.1371/journal.pone.0064652'][:total_usage].should eq(320)
      data['10.1371/journal.pone.0064652'][:viewed_data_present].should eq(true)

      data['10.1371/journal.pone.0064652'][:pubmed].should eq(0)
      data['10.1371/journal.pone.0064652'][:crossref].should eq(0)
      data['10.1371/journal.pone.0064652'][:scopus].should eq(0)
      data['10.1371/journal.pone.0064652'][:cited_data_present].should eq(false)

      data['10.1371/journal.pone.0064652'][:citeulike].should eq(0)
      data['10.1371/journal.pone.0064652'][:mendeley].should eq(0)
      data['10.1371/journal.pone.0064652'][:saved_data_present].should eq(false)

      data['10.1371/journal.pone.0064652'][:nature].should eq(0)
      data['10.1371/journal.pone.0064652'][:researchblogging].should eq(0)
      data['10.1371/journal.pone.0064652'][:scienceseeker].should eq(0)
      data['10.1371/journal.pone.0064652'][:facebook].should eq(0)
      data['10.1371/journal.pone.0064652'][:twitter].should eq(0)
      data['10.1371/journal.pone.0064652'][:wikipedia].should eq(0)
      data['10.1371/journal.pone.0064652'][:discussed_data_present].should eq(false)

      data['10.1371/journal.pmed.0020124'][:plos_html].should eq(568181)
      data['10.1371/journal.pmed.0020124'][:plos_pdf].should eq(106120)
      data['10.1371/journal.pmed.0020124'][:plos_xml].should eq(2161)
      data['10.1371/journal.pmed.0020124'][:plos_total].should eq(676462)

      data['10.1371/journal.pmed.0020124'][:pmc_views].should eq(108674)
      data['10.1371/journal.pmed.0020124'][:pmc_pdf].should eq(18606)
      data['10.1371/journal.pmed.0020124'][:pmc_total].should eq(127280)

      data['10.1371/journal.pmed.0020124'][:total_usage].should eq(803742)
      data['10.1371/journal.pmed.0020124'][:viewed_data_present].should eq(true)

      data['10.1371/journal.pmed.0020124'][:pubmed].should eq(208)
      data['10.1371/journal.pmed.0020124'][:crossref].should eq(528)
      data['10.1371/journal.pmed.0020124'][:scopus].should eq(915)
      data['10.1371/journal.pmed.0020124'][:cited_data_present].should eq(true)

      data['10.1371/journal.pmed.0020124'][:citeulike].should eq(364)
      data['10.1371/journal.pmed.0020124'][:mendeley].should eq(4064)
      data['10.1371/journal.pmed.0020124'][:saved_data_present].should eq(true)

      data['10.1371/journal.pmed.0020124'][:nature].should eq(0)
      data['10.1371/journal.pmed.0020124'][:researchblogging].should eq(9)
      data['10.1371/journal.pmed.0020124'][:scienceseeker].should eq(1)
      data['10.1371/journal.pmed.0020124'][:facebook].should eq(4253)
      data['10.1371/journal.pmed.0020124'][:twitter].should eq(640)
      data['10.1371/journal.pmed.0020124'][:wikipedia].should eq(9)
      data['10.1371/journal.pmed.0020124'][:discussed_data_present].should eq(true)

      data['10.1371/journal.pmed.0020124'][:reddit].should eq(37)
      data['10.1371/journal.pmed.0020124'][:wordpress].should eq(0)

    end

    it "fail to get ALM data for works" do
      report = Report.new
      report.save

      dois = [
        '10.1371/journal.pone.ASDFGQW'
      ]

      report.add_all_dois(dois)

      params = {}
      params[:ids] = dois.sort.join(",")
      url = Alm.get_alm_url(params)

      body = File.read("#{fixture_path}alm_bad_response.json")

      stub_request(:get, "#{url}").to_return(:body => body, :status => 404)

      data = Alm.get_data_for_works(report.report_dois)

      data.size.should eq(0)

    end

    it "get ALM data for valid works in the list" do
      report = Report.new
      report.save

      dois = [
        '10.1371/journal.pone.0064652',
        '10.1371/journal.pmed.AQSWEDR'
      ]

      report.add_all_dois(dois)

      params = {}
      params[:ids] = dois.sort.join(",")
      url = Alm.get_alm_url(params)

      body = File.read("#{fixture_path}alm_good_response2.json")

      stub_request(:get, "#{url}").to_return(:body => body, :status => 200)

      data = Alm.get_data_for_works(report.report_dois)

      data.size.should eq(1)

      data['10.1371/journal.pone.0064652'][:plos_html].should eq(308)
      data['10.1371/journal.pone.0064652'][:plos_pdf].should eq(4)
      data['10.1371/journal.pone.0064652'][:plos_xml].should eq(7)
      data['10.1371/journal.pone.0064652'][:plos_total].should eq(319)

      data['10.1371/journal.pone.0064652'][:pmc_views].should eq(0)
      data['10.1371/journal.pone.0064652'][:pmc_pdf].should eq(1)
      data['10.1371/journal.pone.0064652'][:pmc_total].should eq(1)

      data['10.1371/journal.pone.0064652'][:total_usage].should eq(320)
      data['10.1371/journal.pone.0064652'][:viewed_data_present].should eq(true)

      data['10.1371/journal.pone.0064652'][:pubmed].should eq(0)
      data['10.1371/journal.pone.0064652'][:crossref].should eq(0)
      data['10.1371/journal.pone.0064652'][:scopus].should eq(0)
      data['10.1371/journal.pone.0064652'][:cited_data_present].should eq(false)

      data['10.1371/journal.pone.0064652'][:citeulike].should eq(0)
      data['10.1371/journal.pone.0064652'][:mendeley].should eq(0)
      data['10.1371/journal.pone.0064652'][:saved_data_present].should eq(false)

      data['10.1371/journal.pone.0064652'][:nature].should eq(0)
      data['10.1371/journal.pone.0064652'][:researchblogging].should eq(0)
      data['10.1371/journal.pone.0064652'][:scienceseeker].should eq(0)
      data['10.1371/journal.pone.0064652'][:facebook].should eq(0)
      data['10.1371/journal.pone.0064652'][:twitter].should eq(0)
      data['10.1371/journal.pone.0064652'][:wikipedia].should eq(0)
      data['10.1371/journal.pone.0064652'][:discussed_data_present].should eq(false)

    end

  end

  it "get ALM data for one works" do
    report = Report.new
    report.save

    dois = [
      '10.1371/journal.pmed.0020124'
    ]
    report.add_all_dois(dois)

    params = {}
    params[:ids] = dois.sort.join(",")
    params[:info] = "history"
    params[:source] = "crossref,pubmed,scopus"
    url = Alm.get_alm_url(params)

    body = File.read("#{fixture_path}alm_one_work_history.json")
    stub_request(:get, "#{url}").to_return(:body => body, :status => 200)

    params = {}
    params[:ids] = dois.sort.join(",")
    params[:info] = "event"
    params[:source] = "counter,pmc,citeulike,twitter,researchblogging,nature,scienceseeker,mendeley"
    url = Alm.get_alm_url(params)

    body = File.read("#{fixture_path}alm_one_work_event.json")
    stub_request(:get, "#{url}").to_return(:body => body, :status => 200)

    data = Alm.get_data_for_one_work(report.report_dois)

    data.size.should eq(1)

    data['10.1371/journal.pmed.0020124'][:crossref][:total].should eq(528)
    data['10.1371/journal.pmed.0020124'][:pubmed][:total].should eq(208)

    data['10.1371/journal.pmed.0020124'][:scopus][:total].should eq(915)

    data['10.1371/journal.pmed.0020124'][:counter][:total].should eq(677173)
    data['10.1371/journal.pmed.0020124'][:counter].has_key?(:events).should eq(true)

    data['10.1371/journal.pmed.0020124'][:pmc][:total].should eq(127280)
    data['10.1371/journal.pmed.0020124'][:pmc].has_key?(:events).should eq(true)

    data['10.1371/journal.pmed.0020124'][:citeulike][:total].should eq(364)
    data['10.1371/journal.pmed.0020124'][:citeulike].has_key?(:events).should eq(true)

    data['10.1371/journal.pmed.0020124'][:twitter][:total].should eq(640)
    data['10.1371/journal.pmed.0020124'][:twitter].has_key?(:events).should eq(true)

    data['10.1371/journal.pmed.0020124'][:researchblogging][:total].should eq(9)
    data['10.1371/journal.pmed.0020124'][:researchblogging].has_key?(:events).should eq(true)

    data['10.1371/journal.pmed.0020124'][:nature][:total].should eq(0)
    data['10.1371/journal.pmed.0020124'][:nature].has_key?(:events).should eq(true)

    data['10.1371/journal.pmed.0020124'][:scienceseeker][:total].should eq(1)
    data['10.1371/journal.pmed.0020124'][:scienceseeker].has_key?(:events).should eq(true)

    data['10.1371/journal.pmed.0020124'][:mendeley][:total].should eq(4064)
    data['10.1371/journal.pmed.0020124'][:mendeley].has_key?(:events).should eq(true)

  end

  # Test for an ALM source that should exist, but is not present.  I think this
  # is a bug in ALM (that we have to work around for now).
  it "source missing" do
    doi = "10.1371/journal.pntd.0002063"
    report = Report.new
    report.save
    report.add_all_dois([doi])

    url = Alm.get_alm_url({:ids => doi})
    body = File.read("#{fixture_path}alm_pntd.0002063.json")
    stub_request(:get, "#{url}").to_return(:body => body, :status => 200)
    data = Alm.get_data_for_works(report.report_dois)

    data.size.should eq(1)
    data[doi][:plos_html].should eq(902)
    data[doi][:wos].should eq(0)
  end

  context "get ALM data for visualization" do
    it "use ALM to get the data" do
      report = Report.new
      report.save

      dois = [
        '10.1371/journal.pone.0064652',
        '10.1371/journal.pmed.0020124'
      ]

      report.add_all_dois(dois)

      params = {}
      params[:ids] = dois.sort.join(",")
      url = Alm.get_alm_url(params)

      body = File.read("#{fixture_path}alm_good_response.json")

      stub_request(:get, "#{url}").to_return(:body => body, :status => 200)

      data = Alm.get_data_for_works(report.report_dois)

      data.size.should eq(2)

      data['10.1371/journal.pone.0064652'][:plos_html].should eq(308)
      data['10.1371/journal.pone.0064652'][:plos_pdf].should eq(4)
      data['10.1371/journal.pone.0064652'][:plos_xml].should eq(7)
      data['10.1371/journal.pone.0064652'][:plos_total].should eq(319)

      data['10.1371/journal.pone.0064652'][:pmc_views].should eq(0)
      data['10.1371/journal.pone.0064652'][:pmc_pdf].should eq(1)
      data['10.1371/journal.pone.0064652'][:pmc_total].should eq(1)

      data['10.1371/journal.pone.0064652'][:total_usage].should eq(320)
      data['10.1371/journal.pone.0064652'][:viewed_data_present].should eq(true)

      data['10.1371/journal.pone.0064652'][:pubmed].should eq(0)
      data['10.1371/journal.pone.0064652'][:crossref].should eq(0)
      data['10.1371/journal.pone.0064652'][:scopus].should eq(0)
      data['10.1371/journal.pone.0064652'][:cited_data_present].should eq(false)

      data['10.1371/journal.pone.0064652'][:citeulike].should eq(0)
      data['10.1371/journal.pone.0064652'][:mendeley].should eq(0)
      data['10.1371/journal.pone.0064652'][:saved_data_present].should eq(false)

      data['10.1371/journal.pone.0064652'][:nature].should eq(0)
      data['10.1371/journal.pone.0064652'][:researchblogging].should eq(0)
      data['10.1371/journal.pone.0064652'][:scienceseeker].should eq(0)
      data['10.1371/journal.pone.0064652'][:facebook].should eq(0)
      data['10.1371/journal.pone.0064652'][:twitter].should eq(0)
      data['10.1371/journal.pone.0064652'][:wikipedia].should eq(0)
      data['10.1371/journal.pone.0064652'][:discussed_data_present].should eq(false)


      data['10.1371/journal.pmed.0020124'][:plos_html].should eq(568181)
      data['10.1371/journal.pmed.0020124'][:plos_pdf].should eq(106120)
      data['10.1371/journal.pmed.0020124'][:plos_xml].should eq(2161)
      data['10.1371/journal.pmed.0020124'][:plos_total].should eq(676462)

      data['10.1371/journal.pmed.0020124'][:pmc_views].should eq(108674)
      data['10.1371/journal.pmed.0020124'][:pmc_pdf].should eq(18606)
      data['10.1371/journal.pmed.0020124'][:pmc_total].should eq(127280)

      data['10.1371/journal.pmed.0020124'][:total_usage].should eq(803742)
      data['10.1371/journal.pmed.0020124'][:viewed_data_present].should eq(true)

      data['10.1371/journal.pmed.0020124'][:pubmed].should eq(208)
      data['10.1371/journal.pmed.0020124'][:crossref].should eq(528)
      data['10.1371/journal.pmed.0020124'][:scopus].should eq(915)
      data['10.1371/journal.pmed.0020124'][:cited_data_present].should eq(true)

      data['10.1371/journal.pmed.0020124'][:citeulike].should eq(364)
      data['10.1371/journal.pmed.0020124'][:mendeley].should eq(4064)
      data['10.1371/journal.pmed.0020124'][:saved_data_present].should eq(true)

      data['10.1371/journal.pmed.0020124'][:nature].should eq(0)
      data['10.1371/journal.pmed.0020124'][:researchblogging].should eq(9)
      data['10.1371/journal.pmed.0020124'][:scienceseeker].should eq(1)
      data['10.1371/journal.pmed.0020124'][:facebook].should eq(4253)
      data['10.1371/journal.pmed.0020124'][:twitter].should eq(640)
      data['10.1371/journal.pmed.0020124'][:wikipedia].should eq(9)
      data['10.1371/journal.pmed.0020124'][:discussed_data_present].should eq(true)

    end
  end
end
