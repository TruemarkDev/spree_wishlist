module Spree
  module Api
    module V2
      module Storefront
        class WishedProductsController < Spree::Api::V2::BaseController

          helper Spree::Wishlists::ApiHelpers

          def create
            authorize! :create, Spree::WishedProduct

            @wished_product = Spree::WishedProduct.new(wished_product_attributes)

            current_wishlist_user = spree_current_user
            @wishlist = current_wishlist_user.wishlists.find_by(id: @wished_product[:wishlist_id]) || current_wishlist_user.wishlist

            if @wishlist.include? params[:wished_product][:variant_id]
              @wished_product = @wishlist.wished_products.detect {|wp| wp.variant_id == params[:wished_product][:variant_id].to_i }
            else
              @wished_product.wishlist = @wishlist
              @wished_product.save
            end

            render_serialized_payload(201) { serialize_resource(@wished_product) }
          end

          def update
            @wished_product = Spree::WishedProduct.find(params[:id])
            authorize! :update, @wished_product
            # TODO check if the current wished product wishlist is of ccurrent spree user

            @wished_product.update(wished_product_attributes)
            @wishlist = @wished_product.wishlist

            if @wished_product.errors.empty?
              render_serialized_payload(200) {serialize_resource(@wished_product)}
            else
              render_error_payload(@wished_product.errors)
            end
          end

          def destroy
            @wished_product = Spree::WishedProduct.find(params[:id])
            authorize! :destroy, @wished_product
            @wished_product.destroy

            render_serialized_payload(204) { serialize_resource(@wished_product)}
          end

          private

          def wished_product_attributes
            params.require(:wished_product).permit(:variant_id, :wishlist_id, :remark, :quantity)
          end

          def resource_serializer
            Spree::V2::Storefront::WishedProductSerializer
          end

          def collection_serializer
            Spree::V2::Storefront::WishedProductSerializer
          end

        end # eoc

      end
    end
  end
end
