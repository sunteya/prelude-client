class MainController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :grant

  def grant
    if request.post? && params[:token] == Project.settings.grant_word
      FileUtils.touch Rails.root.join("allow/#{request.ip}")
      UpdateIptableJob.perform_async
      return render 'success', layout: false
    end
    
    render 'input', layout: false
  end
end
