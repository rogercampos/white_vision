# frozen_string_literal: true

module WhiteVision
  class EmailRecord < ActiveRecord::Base
    validates_presence_of :success_rule, if: :track_success?
    validates_inclusion_of :success_rule, in: %w[by_open by_click], allow_nil: true

    def processed?
      !!processed_at
    end

    def delivered?
      !!delivered_at
    end
  end
end
