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

  def unsubscribe
    @notification = Notification.find_by_token(params[:token])
  end

  def destroy
    @notification = Notification.find_by_token(params[:notification][:token])

    redirect_to unsubscribe_path(params[:notification][:token]) and return if @notification.nil?

    @notification.destroy
    if @notification.destroyed?
      flash[:info] = "Successfully unsubscribed"
    else
      flash[:error] = "An error has occurred"
    end

    redirect_to root_url and return
  end
end
