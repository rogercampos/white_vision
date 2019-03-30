require 'white_vision/email'

module WhiteVision
  class HtmlEmail < Email
    def format
      :html
    end

    def message
      apply_replacements(load_template(html_template))
    end


    private

    def html_template
      raise NotImplementedError
    end

    def load_template(path)
      File.read(Config.read_html_templates_root / path)
    end
  end
end