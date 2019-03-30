class Test1 < WhiteVision::HtmlEmail
  def initialize(name)
    @name = name
  end

  def subject
    "This Aaaaa 1"
  end

  def html_template
    "test_1.html"
  end

  def self.initialize_preview
    new("Homer")
  end
end