module Spree
  module Api
    module V2
      module Storefront
        class WishlistsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          def index
            render_serialized_payload { serialize_collection(paginated_collection) }
          end

          def show
            render_serialized_payload { serialize_resource(resource) }
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
