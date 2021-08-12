class CookiesStorage < Wizard::AbstractStorage
  attr_reader :cookies, :cookies_key, :expires

  def initialize(cookies, opts = {})
    @cookies = cookies
    @cookies_key = opts[:cookies_key] || :wcookies
    @expires = 1.day
  end

  def put(key, value)
    @cookies[cookies_key.to_sym] = if @cookies[cookies_key.to_sym].present?
                                     { value: JSON.parse(@cookies[cookies_key.to_sym]).merge(key.to_s => value).to_json, expires: expires }
                                   else
                                     { value: { key.to_s => value }.to_json, expires: expires }
                                   end
  end

  def pull(key)
    JSON.parse(@cookies[cookies_key.to_sym])[key] if @cookies[cookies_key.to_sym].present?
  end

  def remove_all
    @cookies.delete(cookies_key.to_sym)
  end
end
