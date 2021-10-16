module Amz
  class Taxonomy < Amz::Base   
    acts_as_list  
    belongs_to :store
    has_many :taxons, inverse_of: :taxonomy
    has_one  :root, -> { where( parent_id: nil )}, class_name: 'Amz::Taxon', dependent: :destroy  

    validates :name, presence: true 
    validates_uniqueness_of :name, case_sensitive: false , allow_blank: true, scope: :store 

    after_create :set_root
    after_save :set_root_taxon_name 


    default_scope { order("#{table_name}.position, #{table_name}.created_at") }  

    def jstree 
      node = { id: self.root.id, parent: "#", text: self.name, state:{ opened: false, selected: false },  type: "root", children: self.root.children.any?  }
      url = helpers.jstree_admin_store_taxon_path(self.store, Taxon.find(self.root.id) )
      node = node.merge({ url: url }) 
      node
    end 

    private

    def set_root
      self.root ||= Taxon.create!(taxonomy_id: id, name: name, store: store)
    end

    def set_root_taxon_name
      root.update(name: name)
    end

    def helpers
      ActiveAdmin::Helpers::Routes
    end
  end
end
