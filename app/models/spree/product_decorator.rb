module Spree
  Product.class_eval do 

    # This scope selects products in every taxons but not in descendants
    # If you need products only within one taxon use
    #
    #   Spree::Product.taxons_id_eq([x,y])
    add_search_scope :in_all_taxons do |*taxons|
      taxons = get_taxons(taxons) 
      taxons.first ? prepare_all_taxon_conditions(taxons) : scoped
    end

    # doing an all instead of an any in AREL sucks
    def self.prepare_all_taxon_conditions(taxons)
      scope = scoped
      taxons.each_with_index do |taxon,index| 
        tt_name = "taxon#{index}"
        ptt_name = "classification#{index}"
        ptt = ::Spree::Classification.arel_table.alias(ptt_name)
        tt = ::Spree::Taxon.arel_table.alias(tt_name)

        j1 = Arel::Nodes::InnerJoin.new( ptt, Arel::Nodes::On.new( arel_table[:id].eq(ptt[:product_id]) ) )
        j2 = Arel::Nodes::InnerJoin.new( tt, Arel::Nodes::On.new( tt[:id].eq(ptt[:taxon_id]) ) )

        scope = scope.joins(j1,j2).where( "#{tt.name}.id" => taxon.self_and_descendants.pluck(:id) )
      end
      scope
    end

  end
end
