class PreviewController < ApplicationController
  def index
    @tab = :preview_list
    @title = "Preview List"
    @total_found = @cart.size
    set_paging_vars(params[:current_page])

    @results = @cart.items.values
  end
end
