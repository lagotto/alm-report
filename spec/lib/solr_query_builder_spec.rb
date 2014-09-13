require 'spec_helper'
require 'solr/solr_query_builder'

def build_query_test_once(params, expected)
  qb = SolrQueryBuilder.new(params)
  qb.build.should eq(expected)
end

def build_page_block_test_once(params, expected)
  qb = SolrQueryBuilder.new(params)
  qb.page_block.should eq(expected)
end

describe SolrQueryBuilder do
  it "can build simple queries" do
    build_query_test_once({ everything: "everyFoo" }, "everything:everyFoo")

    build_query_test_once(
      { everything: "foo bar blaz" },
      'everything:"foo bar blaz"'
    )

    build_query_test_once(
      { everything: "everyTitle", title: "titleFoo" },
      "everything:everyTitle AND title:titleFoo"
    )

    build_query_test_once(
      { author: "Joe Bob", subject: "Virology" },
      'author:"Joe Bob" AND subject:Virology'
    )
  end

  it "knows how to deal with empty fields" do
    # Empty fields should not be added.
    build_query_test_once(
      { everything: "ignoreRest", author: "", subject: "  " },
      "everything:ignoreRest"
    )
  end

  it "can handle institution and author_country both mapping to affiliate" do
    # Hack where the "pseudo-fields" author_country and institution both map to
    # the actual solr field affiliate.
    build_query_test_once(
      { author_country: "authorCountry" },
      "affiliate:authorCountry"
    )

    build_query_test_once(
      { everything: "everythingInst", institution: "foo institution" },
      'affiliate:"foo institution" AND everything:everythingInst'
    )

    build_query_test_once(
      { author_country: "france", institution: "university of lyon" },
      'affiliate:(france AND "university of lyon")'
    )

    build_query_test_once(
      {
        everything: "some keywords", author_country: "USA",
        institution: "stanford u", subject: "ebola virus"
      },
      'affiliate:(USA AND "stanford u") AND everything:"some keywords" AND ' \
      'subject:"ebola virus"'
    )
  end

  it "removes All Journals from list of journals" do
    # cross_published_journal_name should be ignored if it equals "All Journals"
    build_query_test_once(
      { everything: "fooCross", cross_published_journal_name: "PLOS ONE" },
      'cross_published_journal_name:"PLOS ONE" AND everything:fooCross'
    )

    build_query_test_once(
      {
        everything: "fooNoJournal",
        cross_published_journal_name: "All Journals"
      },
      "everything:fooNoJournal"
    )
  end

  it "can build a simple page block" do
    build_page_block_test_once({}, "rows=25")
    # Page 1 is the default
    build_page_block_test_once({ current_page: "1" }, "rows=25")
    build_page_block_test_once({ current_page: "2" }, "rows=25&start=26")
    build_page_block_test_once({ current_page: "3" }, "rows=25&start=51")
    build_page_block_test_once({ current_page: "4" }, "rows=25&start=76")
  end

  it "start and rows params override default paging" do
    build_page_block_test_once({ start: 17 }, "rows=25&start=17")
    build_page_block_test_once({ start: 100, rows: 200 }, "rows=200&start=100")
    build_page_block_test_once({ rows: 500 }, "rows=500")
  end

  it "doesn't have interactions between build_page_block and build" do
    params = { everything: "hi", title: "bye" }
    qb = SolrQueryBuilder.new(params)
    qb.page_block.should eq("rows=25")
    qb.build.should eq("everything:hi AND title:bye")

    params = { everything: "bad", title: "business", start: 41, rows: 475 }
    qb = SolrQueryBuilder.new(params)
    qb.page_block.should eq("rows=475&start=41")
    qb.build.should eq("everything:bad AND title:business")
  end

  it "generates the correct URL for a query" do
    qb = SolrQueryBuilder.new(everything: "everyTitle", title: "titleFoo")
    qb.build
    url = "http://api.plos.org/search?q=everything:everyTitle%20AND%20" \
      "title:titleFoo&fq=doc_type:full&fq=!article_type_facet:%22Issue%20" \
      "Image%22&fl=id,pmid,publication_date,received_date,accepted_date,title" \
      ",cross_published_journal_name,author_display,editor_display," \
      "article_type,affiliate,subject,financial_disclosure&wt=json" \
      "&facet=false&rows=25"
    qb.url.should eq(url)
  end
end
