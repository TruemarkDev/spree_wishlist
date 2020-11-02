module Spree
  module Api
    module V2
      module Storefront
        class WishlistsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          def index
            @wishlists = current_wishlist_user.wishlists.page(params[:page]).per(params[:per_page])
            render_serialized_payload { @wishlists}
          end

          def show
            authorize! :show, Spree::Wishlist
            @wishlist = Spree::Wishlist.find(params[:id])

            if @wishlist.can_be_read_by?(current_wishlist_user)
              render_serialized_payload { serialize_resource(@wishlist) }
            else
              # TODO: Add i18n here
              render_error_payload('The wishlist is private.')
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
            @wishlist = Spree::Wishlist.find_by(id: params[:id])
            authorize! :update, @wishlist

            @wishlist.update(wishlist_attributes)
            if @wishlist.errors.empty?
              render_serialized_payload(201) {serialize_resource(@wishlist)}
            else
              render_error_payload(@wishlist.errors)
            end

          end

          def destroy
            @wishlist = Spree::Wishlist.find_by(id: params[:id])
            if @wishlist.user_id == current_wishlist_user.id
              @wishlist.destroy!
              render_serialized_payload(204) {serialize_resource(@wishlist)}
            else
              render_error_payload(Spree.t(:unauthorized))
            end
          end

          private

          def wishlist_attributes
            params.require(:wishlist).permit(:name, :is_private, :is_default)
          end

          def collection_serializer
            Spree::V2::Storefront::WishlistSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::WishlistSerializer
          end

          def collection_finder
            Spree::Wishlist
          end

          def paginated_collection
            collection_paginator.new(collection, params).call
          end

          def collection
            collection_finder.new(scope: scope, params: params).execute
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
