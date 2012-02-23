class UsersController < ApplicationController
  def signup
    $request_token = $client.request_token(:oauth_callback => "http://127.0.0.1:3000/users/complete_signup")
    redirect_to $request_token.authorize_url 
  end
  
  def complete_signup
    access_token = $client.authorize($request_token.token, $request_token.secret, :oauth_verifier => params[:oauth_verifier])
    @user = User.first_or_create(:twitter_id => access_token.params["user_id"])
    @user.token = access_token.token
    @user.token_secret = access_token.secret
    client = TwitterOAuth::Client.new(
        :consumer_key => CONSUMER_KEY,
        :consumer_secret => CONSUMER_SECRET,
        :token => @user.token, 
        :secret => @user.token_secret
    )
    rate_limit_status = client.rate_limit_status
    @user.hourly_limit = rate_limit_status["hourly_limit"]
    @user.remaining_hits = rate_limit_status["remaining_hits"]
    @user.reset_time = Time.parse(rate_limit_status["reset_time"])
    saved = @user.save!
    if !saved
      redirect_to "/fail", :user_id => @user.twitter_id
    end
  end
  
  def fail
    @existing_user = User.first(:twitter_id => params[:user_id])  
  end
  
  def call_to_api
    credentials = ActiveRecord::Base.connection.execute("select twitter_id, token, token_secret from users where remaining_hits != 0 limit 1").fetch_hash
    client = TwitterOAuth::Client.new(
        :consumer_key => CONSUMER_KEY,
        :consumer_secret => CONSUMER_SECRET,
        :token => credentials["token"], 
        :secret => credentials["token_secret"]
    )
    json = client.send("get", request.fullpath)
    Thread.new{
      @user = User.first(:twitter_id => credentials["twitter"])
      rate_limit_status = client.rate_limit_status
      @user.hourly_limit = rate_limit_status["hourly_limit"]
      @user.remaining_hits = rate_limit_status["remaining_hits"]
      @user.reset_time = Time.parse(rate_limit_status["reset_time"])
      @user.save!
    }
    render json: json
  end

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end
  def about
    debugger
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {"users_registered" => @users.length, "sum_rate_limits" => @users.collect{|u| u.hourly_limit}.compact.sum, "current_requests" => @users.collect{|u| u.remaining_hits}.compact.sum} }
    end
  end
end
