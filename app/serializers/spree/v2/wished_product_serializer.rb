module Spree
  module V2
    module Storefront
      class WishedProductSerializer < BaseSerializer
        set_type :wished_product

        attributes :total, :display_total
      end
    end
  end
end
