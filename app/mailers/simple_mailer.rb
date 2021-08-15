class SimpleMailer < ApplicationMailer
  def notify_new_job
    mail(to: 'person@email.com', subject: 'New job', template_name: 'job')
  end
end
