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

            if current_wishlist_user.equal?(@wishlist.user)
              render_serialized_payload { serialize_resource(@wishlist) }
            else
              # TODO: Add i18n here
              render_error_payload('The wishlist is private.')
            end
          end

          def create
            
          end

          def update
          end

          def destroy
          end
          private

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
