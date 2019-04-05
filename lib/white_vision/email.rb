module WhiteVision
  module Replacements
    def self.apply(replacements, str, except: [], object: nil)
      except = Array.wrap(except)
      included_replacements = str.scan(/=\w+=/)
      applicable_replacements = replacements.except *except

      unless (included_replacements - applicable_replacements.keys).empty?
        raise "There are replacements pending to be assigned: #{included_replacements - replacements.keys}"
      end

      applicable_replacements.each do |k, value|
        data = if value.respond_to?(:call)
                 object ? value.call(object) : value.call
               else
                 value
               end
        str = str.gsub(k, data)
      end

      str
    end
  end

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
      nil
    end


    private

    def apply_replacements(str, except: [])
      Replacements.apply replacements, str, except: except
    end
  end
end