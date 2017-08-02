module API
  module Entities
    module CCR
      class RepresentationOrder < API::Entities::CCR::BaseEntity
        expose :maat_reference
        expose :representation_order_date, format_with: :utc
      end
    end
  end
end
