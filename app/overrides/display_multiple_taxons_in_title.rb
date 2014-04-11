Deface::Override.new(
  :name => "display_multiple_taxons_in_title",
  :virtual_path => "spree/taxons/show",
  :replace_contents => "[class='taxon-title']",
  :partial => 'shared/taxon_title',
  :original => '6947702c800526ac8ea345fda6363ba1826062b6'
)
