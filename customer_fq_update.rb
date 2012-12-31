require 'bundler'
# for development
# require 'shotgun'
require 'sinatra'
require 'sinatra/flash'
require 'thin'
require 'shopify_api'
require 'httparty'
require 'gmail'
require 'google_drive'
require './sinatra/emails'
require './sinatra/spreadsheets'
require 'active_support/concern'

# Get access to Shopify API
ShopifyAPI::Base.site = "https://63853221c8f1fae9b9b25345b10ec9c8:5ac79471d7d5407d353e015717d6a49b@quincy.myshopify.com/admin"

enable :sessions
set :username, "quincyapps"
set :token, "newyorktokyo"
set :password, "m4nh4tt4n"

helpers do
  def admin?
    request.cookies[settings.username] == settings.token
  end
  def protected!
    redirect "/login" unless admin?
  end
end

get "/" do
  protected!
  erb :index
end

get "/login" do
  erb :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    response.set_cookie(settings.username, settings.token)
    flash[:notice] = "successful login"
    redirect '/'
  else
    flash[:error] = "You didn't say the magic word!"
    redirect '/login'
  end
end

get "/logout" do
  response.set_cookie(settings.username, false)
  flash[:notice] = "Logged Out"
  redirect '/'
end

# customer lookup
post "/data" do
  id = params[:id]
  customer = ShopifyAPI::Customer.find(id)
  @name = customer.first_name + " " + customer.last_name
  @email = customer.email
  @bust = customer.metafields[0].value unless customer.metafields[0].nil?
  @quiz_results = customer.metafields[1].value unless customer.metafields[1].nil?
  @length = customer.metafields[2].value unless customer.metafields[2].nil?
  @waist = customer.metafields[3].value unless customer.metafields[3].nil?
  erb :data
end

# send user info to spreadsheet to contact re inventory
get "/back-in-stock" do
  email = params[:email]
  product = params[:product]
  size = params[:size]
  sku = params[:sku]
  unless email.nil? && product.nil? && size.nil?
    a = Notify.new(email, product, size, sku)
    a.send_data_to_spreadsheet
  end
  redirect "/"
end

# who to send giftcards to
get "/gift-card" do 
  gift_card_giver = params[:gifter_name]
  gift_card_giver_email = params[:gifter_email]
  gift_card_receiver = params[:giftee_name]
  gift_card_receiver_email = params[:giftee_email]
  deliver_date = params[:deliver_date]
  amount = params[:amount]
  message = params[:message]
  unless gift_card_giver.nil?
    a = GiftCard.new(gift_card_giver, gift_card_giver_email, 
                     gift_card_receiver, gift_card_receiver_email, 
                     deliver_date, amount, message)
    a.send_data_to_spreadsheet
  end
  redirect "/"
end

get "/referral" do
  first_name = params[:first_name]
  last_name = params[:last_name]
  email = params[:email]
  unless email.nil?
    a = Referral.new(first_name, last_name, email)
    a.send_data_to_spreadsheet
    a.send_to_quincy
  end
end

get "/new-user" do
  name = params[:name]
  email = params[:email]
  unless name.nil? && email.nil?
    a = NewUser.new(name, email)
    a.send_data_to_spreadsheet
  end
  redirect "/"
end

# send customr folowup emails
post "/customer-followup" do
  start = params[:start].to_i
  finish = params[:end].to_i
  # array of columns that gdrive gem pulls info from
  followup = (start..finish).to_a

  # send email
  followup.each do |user|
    mail_users(user, "customers")
  end
  "Done"
end

# send emails to request reviews
post "/review-followup" do
  start = params[:start].to_i
  finish = params[:end].to_i
  # array of columns that gdrive gem pulls info from
  followup = (start..finish).to_a

  followup.each do |user|
    mail_users(user, "reviews")
  end
  "Done"
end