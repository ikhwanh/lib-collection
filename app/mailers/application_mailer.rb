class ApplicationMailer < ActionMailer::Base
  include EmailTrackable

  default from: 'from@example.com'
  layout 'mailer'
  prepend_view_path 'app/views/mailers'

  def proxy_url(_original_url)
    m_url(r: 'http://www.google.com')
  end

  def tracking_img_url
    # token = generate_token
    img_url(key: 'test')
  end
end
