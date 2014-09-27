class PreviewController < ApplicationController
  def index
    @tab = :preview_list
    @title = "Preview List"
    @total_found = items.size
    set_paging_vars(params[:current_page])
    @results = items
  end

  private

  def items
    @cart.items.values
  end
end
