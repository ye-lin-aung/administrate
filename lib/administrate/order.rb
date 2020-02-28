module Administrate
  class Order
    def order_by_association(relation)
      return order_by_count(relation) if has_many_attribute?(relation)

      order_attribute =
        "#{relation.klass}Dashboard".constantize.send(:new)
        .attribute_types
        .fetch(attribute.to_sym, nil)
        .try(:options)
        .try(:[], :order)

      if belongs_to_attribute?(relation)
        if order_attribute.present?
          return order_by_order_attribute(relation, order_attribute)
        else
          return order_by_id(relation)
        end
      end

      relation
    end

    def order_by_order_attribute(relation, order_attribute)
      relation
        .joins(attribute.to_sym)
        .order(
          attribute
        .titlecase
        .constantize
        .arel_table[order_attribute.to_s]
        .lower
        .send(direction.to_sym),
      )
    end
  end
end
