class PreviewController < ApplicationController
  def index
    @tab = :preview_list
    @title = "Preview List"
    @total_found = items.size
    set_paging_vars(params[:current_page])

    @results = paginated_results
  end

  private

  def items
    @cart.items.values
  end

  def paginated_results
    items[@start_result-1..@end_result-1]
  end
end
