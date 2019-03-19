# frozen_string_literal: true

module WhiteVision
  class EventProcessor
    def self.process(json_payload)
      # We may receive duplicated events in the same payload
      # https://sendgrid.com/docs/API_Reference/Webhooks/event.html#-Duplicate-Events
      json_payload.uniq { |x| x['sg_event_id'] }.each { |x| new(x).run! }
    end

    def initialize(json)
      @json = json
      @email_id = @json['peleka_id']
    end

    def run!
      # Ignore callbacks for emails not sent from WhiteVision
      return unless @email_id

      ActiveRecord::Base.transaction do
        @email = Email.lock.find_by(id: @email_id)

        # Ignore callback if the email no longer exists in the Repository
        return unless @email

        dispatch(@json['event'], @json['type'])
      end
    end

    def dispatch(event, type)
      case event
        when 'processed'
          process_email
        when 'delivered'
          deliver_email
        when 'open'
          open_email
        when 'click'
          click_email
        when 'dropped'
          drop_email
        when 'bounce'
          case type
            when 'bounce'
              bounce_email
            when 'blocked'
              block_email
          end
      end
    end

    private

    def process_email
      @email.update_attributes!(processed_at: event_time)
    end

    def deliver_email
      @email.update_attributes!(delivered_at: event_time)
    end

    def open_email
      new_data = {
        last_open_at: max_of(event_time, @email.last_open_at),
        first_open_at: min_of(event_time, @email.first_open_at),
        total_opens: @email.total_opens + 1
      }

      if @email.track_success && @email.success_rule == 'by_open'
        new_data[:success] = true
      end

      new_data[:last_open_from_ip] = @json['ip'] if @email.last_open_from_ip.nil?

      @email.update_attributes!(new_data)
    end

    def click_email
      new_data = {
        last_click_at: max_of(event_time, @email.last_click_at),
        first_click_at: min_of(event_time, @email.first_click_at),
        total_clicks: @email.total_clicks + 1
      }

      if @email.track_success &&
         @email.success_rule == 'by_click' &&
         (@email.success_url_regexp.nil? || Regexp.new(@email.success_url_regexp).match(@json['url']))

        new_data[:success] = true
      end

      @email.update_attributes!(new_data)
    end

    def drop_email
      @email.update_attributes!(dropped: true, drop_reason: @json['reason'])
    end

    def bounce_email
      @email.update_attributes!(bounced: true)
    end

    def block_email
      @email.update_attributes!(blocked: true)
    end

    def event_time
      Time.at @json['timestamp']
    end

    def max_of(a, b)
      [a, b].compact.max
    end

    def min_of(a, b)
      [a, b].compact.min
    end
  end
end
