module WhiteVision
  class Email
    def subject
      raise NotImplementedError
    end

    def message
      raise NotImplementedError
    end

    def replacements
      {}
    end

    def template_id
      self.class.name.demodulize.underscore
    end

    def track_success?
      raise NotImplementedError
    end

    def format
      raise NotImplementedError
    end

    def success_rule
      raise(NotImplementedError) if track_success?
    end

    def success_url_regexp
      nil
    end

    def extra_data
      {}
    end

    def self.initialize_preview
      raise NotImplementedError
    end


    private

    def apply_replacements(str, extra_replacements = {})
      included_replacements = str.scan(/=\w+=/)
      applicable_replacements = replacements.merge(extra_replacements)

      unless (included_replacements - applicable_replacements.keys).empty?
        raise "There are replacements pending to be assigned: #{included_replacements - replacements.keys}"
      end

      applicable_replacements.each do |k, value|
        str = str.gsub(k, value)
      end

      str
    end
  end
end