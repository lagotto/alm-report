describe SearchResult, vcr: true do
  if Search.plos?
    it "correctly parses and geolocates affiliations" do
      result = Search.find_by_ids(["10.1371/journal.pone.0010031"]).first
      expect(result.affiliations).to eq [
        {
          :full=>"Center for Systems Biology, Michigan State University, East Lansing, Michigan, United States of America",
          :address=>"East Lansing, Michigan, United States of America",
          :institution=>"Center for Systems Biology, Michigan State University",
          :location=>{:lat=>42.737, :lng=>-84.4839}
        },
        {
          :full=>"Cellular and Molecular Biology Lab, Department of Chemical Engineering and Materials Science, Michigan State University, East Lansing, Michigan, United States of America",
          :address=>"East Lansing, Michigan, United States of America",
          :institution=>"Cellular and Molecular Biology Lab, Department of Chemical Engineering and Materials Science, Michigan State University",
          :location=>{:lat=>42.737, :lng=>-84.4839}
        },
        {
          :full=>"Cell and Molecular Biology Program, Michigan State University, East Lansing, Michigan, United States of America",
          :address=>"East Lansing, Michigan, United States of America",
          :institution=>"Cell and Molecular Biology Program, Michigan State University",
          :location=>{:lat=>42.737, :lng=>-84.4839}
        },
        {
          :full=>"Department of Chemical Engineering and Materials Science, Michigan State University, East Lansing, Michigan, United States of America",
          :address=>"East Lansing, Michigan, United States of America",
          :institution=>"Department of Chemical Engineering and Materials Science, Michigan State University",
          :location=>{:lat=>42.737, :lng=>-84.4839}
        },
        {
          :full=>"Department of Mechanical Engineering, Michigan State University, East Lansing, Michigan, United States of America",
          :address=>"East Lansing, Michigan, United States of America",
          :institution=>"Department of Mechanical Engineering, Michigan State University",
          :location=>{:lat=>42.737, :lng=>-84.4839}
        },
        {
          :full=>"Department of Biochemistry and Molecular Biology, Michigan State University, East Lansing, Michigan, United States of America",
          :address=>"East Lansing, Michigan, United States of America",
          :institution=>"Department of Biochemistry and Molecular Biology, Michigan State University",
          :location=>{:lat=>42.737, :lng=>-84.4839}
        },
        {
          :full=>"Department of Computer Science and Engineering, Michigan State University, East Lansing, Michigan, United States of America",
          :address=>"East Lansing, Michigan, United States of America",
          :institution=>"Department of Computer Science and Engineering, Michigan State University",
          :location=>{:lat=>42.737, :lng=>-84.4839}
        }
      ]
    end
  end

  it "gets the journal title with most information", vcr: true do
    result = Search.find_by_ids(["10.1371/journal.pcbi.1002727"])[0]

    expect(result.journal.downcase).to eq("plos computational biology")
  end

  it "handles results without affiliations" do
    result = Search.find_by_ids(["10.1371/journal.pbio.1001046"])[0]
    expect(result.affiliations).to eq nil
  end
end
