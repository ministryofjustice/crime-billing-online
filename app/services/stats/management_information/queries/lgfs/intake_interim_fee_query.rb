# frozen_string_literal: true

# https://docs.google.com/spreadsheets/d/1LgECNzbhOJ0MPS-2jbsXVyvtS2Q2TnjDQ4o42tyhU_g/edit#gid=1744254165
# Where scheme = LGFS
# Where bill type = LGFS interim
# And Where submission type = new
# And Where originally submitted = DATE specified for this lookup *
# And Where disk evidence = no
# And Where claim total < 20,000
#

Dir.glob(File.join(__dir__, '..', 'base_count_query.rb')).each { |f| require_dependency f }

module Stats
  module ManagementInformation
    module Lgfs
      class IntakeInterimFeeQuery < BaseCountQuery
        private

        def query
          <<~SQL
            WITH journeys AS (
              #{journeys_query}
            )
            SELECT count(*)
            FROM journeys j
            WHERE j.scheme = 'LGFS'
            AND trim(lower(j.bill_type)) = 'lgfs interim'
            AND j.journey -> 0 ->> 'to' = 'submitted'
            AND date_trunc('day', j.#{@date_column_filter}) = '#{@day}'
            AND NOT j.disk_evidence
            AND j.claim_total::float < 20000.00
          SQL
        end
      end
    end
  end
end
