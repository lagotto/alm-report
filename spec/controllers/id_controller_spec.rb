require "spec_helper"

describe IdController do
  it "validates dois" do
    IdController.validate_doi(nil).should eq(nil)
    IdController.validate_doi("").should eq(nil)
    IdController.validate_doi("foo").should eq(nil)
    IdController.validate_doi("info:doi/10.1371/journal.pone.0049349").
      should eq("10.1371/journal.pone.0049349")
    IdController.validate_doi("10.1371/journal.pmed.1000077").
      should eq("10.1371/journal.pmed.1000077")

    IdController.validate_doi(
      "10.1371/currents.dis.ad70cd1c8bc585e9470046cde334ee4b"
    ).should eq("10.1371/currents.dis.ad70cd1c8bc585e9470046cde334ee4b")

    IdController.validate_doi(
      "info:doi/10.1371/currents.tol.53ba26640df0ccaee75bb165c8c26288"
    ).should eq("10.1371/currents.tol.53ba26640df0ccaee75bb165c8c26288")

    IdController.validate_doi("doi/10.1371/currents.RRN1226").
      should eq("10.1371/currents.RRN1226")

    IdController.validate_doi("10.1371/4f8d4eaec6af8").
      should eq("10.1371/4f8d4eaec6af8")

    IdController.validate_doi("info:doi/10.1371/5035add8caff4").
      should eq("10.1371/5035add8caff4")

    IdController.validate_doi("doi/10.1371/4fd1286980c08").
      should eq("10.1371/4fd1286980c08")

    IdController.validate_doi("doi:10.1021/ac1014832").
      should eq("10.1021/ac1014832")
  end

  it "POST #process_upload", vcr: true do
    file = fixture_file_upload "sample_upload_file.csv", "text/plain"
    post :process_upload, :"upload-file-field" => file

    response.redirect_url.should eq('http://test.host/preview')
  end

  it "adds a work by id", vcr: true do
    doi = "10.1371/journal.pone.0061406"
    post :save, "doi-pmid-1" => doi

    expect(response).to be_redirect
    expect(session[:dois]).to eq [doi]
  end
end
