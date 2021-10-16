module Amz
    class TestMailer < Amz::BaseMailer
      def test_email(email)
        subject = "#{current_store.name} Test Mailer"
        mail(to: email, from: from_address, subject: subject)
      end
    end
end
