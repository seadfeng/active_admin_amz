module Amz
    module Core
        module Helpers
            class Taxon
                attr_reader :data, :store_id, :take
                def initialize(data, store_id = 1)
                    @data = data
                    @store_id = store_id
                    taxon_names = data.split("/") # data = "Categories/Home & Kitchen/Kitchen & Dining", 1
                    return nil if taxon_names.count != 3
                    taxon_root = Amz::Taxon.find_by(store_id: store_id, name: taxon_names.first.rstrip.lstrip )
                    taxonomy = taxon_root.taxonomy
                    return nil if taxon_root.blank?
                    taxon_one =  Amz::Taxon.find_or_create_by(name: taxon_names[1].rstrip.lstrip, store_id: store_id, parent_id: taxon_root.id, taxonomy_id: taxonomy.id )
                    taxon_two =  Amz::Taxon.find_or_create_by(name: taxon_names[2].rstrip.lstrip, store_id: store_id, parent_id: taxon_one.id, taxonomy_id: taxonomy.id )
                    @take = taxon_two
                end 
            end
        end
    end
end