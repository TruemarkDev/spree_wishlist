module Spree
  module V2
    module Storefront
      class WishlistSerializer < BaseSerializer
        set_type :wishlist

        attributes :name, :is_private, :is_default

        has_one :user
        has_many :wished_products
      end
    end
  end
end
