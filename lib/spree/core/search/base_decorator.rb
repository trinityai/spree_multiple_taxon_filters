module Spree
  module Core
    module Search
      Base.class_eval do
        protected
          alias_method :original_get_base_scope, :get_base_scope
          alias_method :original_prepare, :prepare

          def get_base_scope
            base_scope = Spree::Product.active
            base_scope = base_scope.in_taxon(taxon) unless taxon.blank?
            base_scope = base_scope.in_all_taxons(taxons) unless taxons.blank?
            base_scope = get_products_conditions_for(base_scope, keywords)
            base_scope = add_search_scopes(base_scope)
            base_scope
          end

          def prepare(params)
            original_prepare(params)
            @properties[:taxons] = params[:taxons].blank? ? nil : Spree::Taxon.find(params[:taxons])
          end
      end
    end
  end
end
