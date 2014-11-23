class Api::ReportsController < ApplicationController
  respond_to :json

  # API
  def show
    @report = Report.find(params[:id])
    render json: { report: @report }
  end
end
