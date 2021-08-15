module EmailTrackable
  def render(options, &block)
    response_body = super(options, &block)

    doc = Nokogiri::HTML(response_body)
    doc.css('a[href]').each do |a|
      a.attributes['href'].value = proxy_url(a.attributes['href'].value)
    end
    doc.at('body').add_child("<p style='display:none;visibility:none;margin:0;padding:0;line-height:0;'><img src='#{tracking_img_url}' alt=''></p>")

    doc.to_html
  end

  def proxy_url(original_url)
    raise NotImplementedError
  end

  def tracking_img_url
    raise NotImplementedError
  end
end
