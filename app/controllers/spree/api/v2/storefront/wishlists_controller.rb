module Spree
  module Api
    module V2
      module Storefront
        class WishlistsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          before_action :find_wishlist, :only => [:destroy, :show, :update]

          def index
            @wishlists = current_wishlist_user.wishlists.page(params[:page]).per(params[:per_page])
            render_serialized_payload { @wishlists}
          end

          def show
            authorize! :show, Spree::Wishlist

            if @wishlist.can_be_read_by?(current_wishlist_user)
              render_serialized_payload { serialize_resource(@wishlist) }
            else
              render_error_payload(Spree.t(:private_wishlist))
            end
          end

          def create
            authorize! :create, Spree::Wishlist
            @wishlist = current_wishlist_user.wishlists.new(wishlist_attributes)
            @wishlist.save

            if @wishlist.errors.empty?
              render_serialized_payload(201) {serialize_resource(@wishlist)}
            else
              render_error_payload(@wishlist.errors)
            end

          end

          def update
            authorize! :update, @wishlist

            @wishlist.update(wishlist_attributes)

            if @wishlist.errors.empty?
              render_serialized_payload(201) {serialize_resource(@wishlist)}
            else
              render_error_payload(@wishlist.errors)
            end

          end

          def destroy
            authorize! :destroy, @wished_product

            if @wishlist.user_id == current_wishlist_user.id
              @wishlist.destroy!
              render_serialized_payload(204) {serialize_resource(@wishlist)}
            else
              render_error_payload(Spree.t(:unauthorized))
            end
          end

          private

          def find_wishlist
            @wishlist = Spree::Wishlist.find_by(id: params[:id])
          end

          def wishlist_attributes
            params.require(:wishlist).permit(:name, :is_private, :is_default)
          end

          def resource_serializer
            Spree::V2::Storefront::WishlistSerializer
          end

          # to allow managing of other users' list by admins
          def current_wishlist_user
            spree_current_user
          end

          def resource
            # TODO @prakash: we may not need permalink finder
            scope.find_by(permalink: params[:id]) || scope.find(params[:id])
          end

          def scope
            Spree::Wishlist.accessible_by(current_ability, :show).includes(scope_includes)
          end

          def scope_includes
            {
              wished_products: []
            }
          end
        end
      end
    end
  end
end
