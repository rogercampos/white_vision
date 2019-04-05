require 'test_helper'

module WhiteVision
  class EmailTest < ActiveSupport::TestCase
    class MyBaseEmail < WhiteVision::HtmlEmail
      def initialize(name = "Jon")
        @name = name
      end

      def message
        apply_replacements "Hello =name=!"
      end

      def replacements
        { "=name=" => @name }
      end
    end

    test 'derives template_id automatically' do
      email = MyBaseEmail.new
      assert_equal "my_base_email", email.template_id
    end

    test 'applies replacements' do
      email = MyBaseEmail.new "Pepe"
      assert_equal 'Hello Pepe!', email.message
    end
  end
end