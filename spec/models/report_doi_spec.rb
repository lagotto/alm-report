require "spec_helper"

describe ReportDoi do
  it "builds subject string" do
    subject = [
      "/Biology and life sciences/Genetics/Genomics/Genome analysis/Genomic libraries",
      "/Biology and life sciences/Organisms/Animals/Invertebrates/Arthropoda/Insects/Drosophila/Drosophila melanogaster",
      "/Biology and life sciences/Evolutionary biology/Organismal evolution",
      "/Research and analysis methods/Molecular biology techniques/Sequencing techniques/Sequence analysis",
      "/Biology and life sciences/Genetics/Genomics/Genome evolution",
      "/Biology and life sciences/Computational biology/Genome analysis/Genomic libraries",
      "/Biology and life sciences/Genetics/Heredity/Homozygosity",
      "/Biology and life sciences/Microbiology/Microbial genomics/Bacterial genomics",
      "/Biology and life sciences/Evolutionary biology/Molecular evolution/Genome evolution",
      "/Biology and life sciences/Genetics/Genomics/Microbial genomics/Bacterial genomics",
      "/Biology and life sciences/Genetics/Genomics/Animal genomics/Invertebrate genomics",
      "/Research and analysis methods/Model organisms/Animal models/Drosophila melanogaster",
      "/Biology and life sciences/Computational biology/Genome evolution",
      "/Biology and life sciences/Microbiology/Bacteriology/Bacterial genomics"
    ]

    report_doi = ReportDoi.new
    report_doi.solr = {}
    report_doi.solr["subject"] = subject
    report_doi.send(:subject_string).should eq(
      "Bacterial genomics,Drosophila melanogaster,Genome evolution," \
      "Genomic libraries,Homozygosity,Invertebrate genomics," \
      "Organismal evolution,Sequence analysis"
    )
  end
end
