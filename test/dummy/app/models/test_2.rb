class Test2 < WhiteVision::HtmlEmail
  def initialize(name)
    @name = name
  end

  def subject
    "cuca merda"
  end

  def html_template
    "test_1.html"
  end

  def self.initialize_preview
    new("Homer")
  end
end