class ReportDoi < ActiveRecord::Base
  belongs_to :report
  attr_accessor :solr, :alm, :display_index

  def alm
    @alm || {}
  end
end
