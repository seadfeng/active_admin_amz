module Amz
    module StoreReviewScopes
      extend ActiveSupport::Concern
  
      included do
        cattr_accessor :search_scopes do
          []
        end
  
        def self.add_search_scope(name, &block)
          singleton_class.send(:define_method, name.to_sym, &block)
          search_scopes << name.to_sym
        end
  
        def self.simple_scopes
          [
            :ascend_by_updated_at,
            :descend_by_updated_at,
            :ascend_by_name,
            :descend_by_name
          ]
        end
  
        def self.add_simple_scopes(scopes)
          scopes.each do |name|
            # We should not define price scopes here, as they require something slightly different
            next if name.to_s.include?('master_price')
  
            parts = name.to_s.match(/(.*)_by_(.*)/)
            scope(name.to_s, -> { order(Arel.sql("#{StoreReview.quoted_table_name}.#{parts[2]} #{parts[1] == 'ascend' ? 'ASC' : 'DESC'}")) })
          end
        end
   
  
        add_simple_scopes simple_scopes 
  
        # This scope selects Reviews in taxon AND all its descendants
        # If you need Reviews only within one taxon use
        #
        #   Spree::Review.joins(:taxons).where(Taxon.table_name => { id: taxon.id })
        #
        # If you're using count on the result of this scope, you must use the
        # `:distinct` option as well:
        #
        #   Spree::Review.in_taxon(taxon).count(distinct: true)
        #
        # This is so that the count query is distinct'd:
        #
        #   SELECT COUNT(DISTINCT "spree_Reviews"."id") ...
        #
        #   vs.
        #
        #   SELECT COUNT(*) ...
        add_search_scope :in_taxon do |taxon|
          includes(:classifications).
            where("#{Classification.table_name}.taxon_id" => taxon.self_and_descendants.pluck(:id)).
            order("#{Classification.table_name}..position ASC")
        end
  
        # This scope selects Reviews in all taxons AND all its descendants
        # If you need Reviews only within one taxon use
        #
        #   Spree::Review.taxons_id_eq([x,y])
        add_search_scope :in_taxons do |*taxons|
          taxons = get_taxons(taxons)
          taxons.first ? prepare_taxon_conditions(taxons) : where(nil)
        end
   
        # Finds all Reviews that have a name containing the given words.
        add_search_scope :in_name do |words|
          like_any([:name], prepare_words(words))
        end 
  
        # Finds all Reviews that have the ids matching the given collection of ids.
        # Alternatively, you could use find(collection_of_ids), but that would raise an exception if one Review couldn't be found
        add_search_scope :with_ids do |*ids|
          where(id: ids)
        end 
  
        add_search_scope :not_deleted do
          where("#{StoreReview.quoted_table_name}.deleted_at IS NULL or #{StoreReview.quoted_table_name}.deleted_at >= ?", Time.zone.now)
        end 
  
        add_search_scope :taxons_name_eq do |name|
          group("#{StoreReview.quoted_table_name}.id").joins(:taxons).where(Taxon.arel_table[:name].eq(name))
        end 

        add_search_scope :reviews_name_eq do |name|
            group("#{StoreReview.quoted_table_name}.id").joins(:review).where(Review.arel_table[:name].eq(name))
        end 
  
        # specifically avoid having an order for taxon search (conflicts with main order)
        def self.prepare_taxon_conditions(taxons)
          ids = taxons.map { |taxon| taxon.self_and_descendants.pluck(:id) }.flatten.uniq
          joins(:classifications).where(Classification.table_name => { taxon_id: ids })
        end
        private_class_method :prepare_taxon_conditions
  
        # Produce an array of keywords for use in scopes.
        # Always return array with at least an empty string to avoid SQL errors
        def self.prepare_words(words)
          return [''] if words.blank?
  
          a = words.split(/[,\s]/).map(&:strip)
          a.any? ? a : ['']
        end
        private_class_method :prepare_words
  
        def self.get_taxons(*ids_or_records_or_names)
          taxons = Taxon.table_name
          ids_or_records_or_names.flatten.map do |t|
            case t
            when Integer then Taxon.find_by(id: t)
            when ApplicationRecord then t
            when String
              Taxon.find_by(name: t) ||
                Taxon.where("#{taxons}.permalink LIKE ? OR #{taxons}.permalink = ?", "%/#{t}/", "#{t}/").first
            end
          end.compact.flatten.uniq
        end
        private_class_method :get_taxons
      end
    end
  end
