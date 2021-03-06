module Administrate
  class Order
    def initialize(attribute = nil, direction = nil, order = nil)
      @attribute = attribute
      @direction = direction || :asc

    end

    def apply(relation)
      order = "#{relation.table_name}.#{attribute} #{direction}"

      return order_by_association(relation) unless
      reflect_association(relation).nil?



      return relation.reorder(Arel.sql(order)) if
      relation.columns_hash.keys.include?(attribute.to_s)

      relation
    end

    def ordered_by?(attr)
      attr.to_s == attribute.to_s
    end

    def order_params_for(attr)
      {
        order: attr,
        direction: reversed_direction_param_for(attr)
      }
    end

    attr_reader :direction

    private

    attr_reader :attribute

    def reversed_direction_param_for(attr)
      if ordered_by?(attr)
        opposite_direction
      else
        :asc
      end
    end

    def opposite_direction
      direction.to_sym == :asc ? :desc : :asc
    end

    def order_by_association(relation)
      return order_by_count(relation) if has_many_attribute?(relation)
      if belongs_to_attribute?(relation)

        if attribute == "user"
            return order_by_order_attribute(relation, "email")
          elsif attribute == "video"
            return order_by_order_attribute(relation, "videos.title")
          elsif attribute == "question_group"
            return order_by_order_attribute(relation, "question_groups.title")

          else
            return order_by_id(relation)
          end
      end

      relation
    end

    def order_by_count(relation)
      relation.
        left_joins(attribute.to_sym).
        group(:id).
        reorder("COUNT(#{attribute}.id) #{direction}")
    end

    def order_by_id(relation)
      relation.reorder("#{foreign_key(relation)} #{direction}")
    end

    def has_many_attribute?(relation)
      reflect_association(relation).macro == :has_many
    end

    def belongs_to_attribute?(relation)
      reflect_association(relation).macro == :belongs_to
    end

    def reflect_association(relation)
      relation.klass.reflect_on_association(attribute.to_s)
    end

    def order_by_order_attribute(relation, order_attribute)
      relation
        .joins(attribute.to_sym)
        .order(
          "#{order_attribute} #{direction}"
      )
    end

    def foreign_key(relation)
      reflect_association(relation).foreign_key
    end
  end
end
