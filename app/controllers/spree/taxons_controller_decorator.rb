module Spree
  TaxonsController.class_eval do
    alias_method :original_show, :show unless method_defined?(:original_show)

    def show
      ids = params[:id].split('/').each_slice(2).to_a
      @selected_taxons = ids.collect {|id| Taxon.find_by_permalink!(id.join('/'))}
      taxon_ids = @selected_taxons.collect {|t| t.id}

      @taxon = @selected_taxons.first
      @searcher = build_searcher(params.merge(:taxons => taxon_ids))
      @products = @searcher.retrieve_products
    end

  end
end
