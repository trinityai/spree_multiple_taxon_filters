module Spree
  TaxonsController.class_eval do
    alias_method :original_show, :show

    def show
      ids = params[:id].split('/').each_slice(2).to_a
      @taxons = ids.collect {|id| Taxon.find_by_permalink!(id.join('/'))}
      taxon_ids = @taxons.collect {|t| t.id}

      @taxon = @taxons.first
      @searcher = build_searcher(params.merge(:taxons => taxon_ids))
      @products = @searcher.retrieve_products
    end

  end
end
