class NotificationsController < ApplicationController
  def create
    @notification = Notification.new(email: params[:email])

    respond_to do |format|
      if Notification.exists?(email: params[:email])
        format.json { render :json => {:status => false, :reason => "Email already subscribed."}, :status => :unprocessable_entity }
      elsif @notification.save
        format.json { render :json => @notification.as_json(only: [:email]), :status => :ok }
      else
        format.json { render :json => {:status => false}, :status => :unprocessable_entity }
      end
    end
  end
end
