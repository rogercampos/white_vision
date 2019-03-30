require 'test_helper'

module WhiteVision
  class HtmlEmailTest < ActiveSupport::TestCase
    class MyEmail < WhiteVision::HtmlEmail
      def initialize(name = "Jon")
        @name = name
      end

      def html_template
        'my_email.html'
      end

      def replacements
        { "=name=" => @name }
      end
    end

    test 'is in html format' do
      email = MyEmail.new
      assert_equal :html, email.format
    end

    test 'returns an appropriate message' do
      email = MyEmail.new "Pepe"
      assert_equal '<h1>Hello Pepe!</h1>', email.message
    end
  end
end