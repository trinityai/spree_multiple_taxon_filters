module Spree
  BaseHelper.class_eval do
    alias_method :original_breadcrumbs, :breadcrumbs unless method_defined?(:original_breadcrumbs)
    alias_method :original_taxons_tree, :taxons_tree unless method_defined?(:original_taxons_tree)
    alias_method :original_seo_url, :seo_url  unless method_defined?(:original_seo_url)

    def current_taxons
      @selected_taxons || []
    end

    def taxon_title_text
      current_taxons.collect {|t| t.name}.join(', ').html_safe
    end

    def breadcrumbs(taxon, separator="&nbsp;&raquo;&nbsp;")
      if current_taxons.empty?
        return original_breadcrumbs( taxon, separator )
      end

      return "" if current_page?("/") || taxon.nil?
      separator = raw(separator)
      crumbs = [content_tag(:li, link_to(Spree.t(:home), spree.root_path))]
      if taxon
        crumbs << content_tag(:li, link_to(Spree.t(:products), products_path))
        crumbs << current_taxons.collect { |t| content_tag(:li, link_to(t.name, seo_url(t))) } unless current_taxons.empty?
      else
        crumbs << content_tag(:li, content_tag(:span, Spree.t(:products)))
      end
      crumb_list = content_tag(:ul, raw(crumbs.flatten.map{|li| li.mb_chars}.join(separator)), class: 'inline')
      content_tag(:nav, crumb_list, id: 'breadcrumbs', class: 'sixteen columns')
    end

    def taxons_tree(root_taxon, current_taxon, max_level = 1)
      return '' if max_level < 1 || root_taxon.children.empty?

      all_link = link_to( t(:all), seo_url_without( root_taxon.permalink ) )
      content_tag :ul, class: 'taxons-list' do
        items = root_taxon.children.map do |taxon|
          css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
          content_tag :li, class: css_class do
           link_to(taxon.name, seo_url(taxon)) +
           taxons_tree(taxon, current_taxon, max_level - 1)
          end
        end.join("\n")
        items << "\n"
        items << content_tag( :li, all_link ) 
        items.html_safe
      end
    end

    def seo_url(taxon)
      root_taxon_permalink = taxon.root.permalink
      taxons = (taxons_without( root_taxon_permalink ) + [taxon]).uniq
      return expanded_seo_url( taxons )
    end

    def taxons_without( root_taxon_permalink )
      current_taxons.select { |t| not t.permalink.start_with? root_taxon_permalink }
    end

    def seo_url_without( root_taxon_permalink )
      taxons = taxons_without( root_taxon_permalink )
      if taxons.empty?
        return products_path
      else
        return expanded_seo_url( taxons )
      end
    end

    def expanded_seo_url( taxons )
      return spree.nested_taxons_path( taxons.collect {|t| t.permalink}.sort.join('/') )
    end


  end
end
