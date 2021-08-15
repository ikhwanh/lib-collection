class TrackingController < ApplicationController
  # you have to implement token so that the user can only make a request when opening an email

  def img
    return render(file: Rails.root.join('public', '403.html'), status: 403) if params[:key].blank?

    puts "User opening an email, the key is #{params[:key]}"

    send_file(
      Rails.root.join('app', 'assets', 'images', 'tracking_pixel.png').to_s,
      type: 'image/png',
      disposition: 'inline'
    )
  end

  def redirector
    return render(file: Rails.root.join('public', '403.html'), status: 403) if params[:r].blank?

    redirect_to params[:r]
  end
end
