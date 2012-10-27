require 'bundler'
# for development
# require 'shotgun'
require 'sinatra'
require 'thin'
require 'shopify_api'
require 'httparty'
require 'gmail'
require 'google_drive'
require './sinatra/emails'
require 'rack-flash'
require 'sinatra/redirect_with_flash'

# Get access to Shopify API
ShopifyAPI::Base.site = "https://63853221c8f1fae9b9b25345b10ec9c8:5ac79471d7d5407d353e015717d6a49b@quincy.myshopify.com/admin"

enable :sessions
use Rack::Flash, :sweep => true
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

class Gdoc
  include HTTParty
  
  def initialize(email, product, size)
    @email = email
    @product = product
    @size = size
  end
  
  def send_data
    options = { :body => { email: @email, product: @product, size: @size }}
    self.class.post("https://script.google.com/a/macros/quincyapparel.com/s/AKfycbxSKEvKGze2BJiQE8_0iSeYrsmW20Mmg09ultyNgoTBD7rtAdI/exec", options)
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
    redirect '/', :notice => "Successful Login"
  else
    redirect '/login', :error => "Try Again"
  end
end

get "/logout" do
  response.set_cookie(settings.username, false)
  redirect '/', :notice => "Logged Out"
end

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

get "/back-in-stock" do
  email = params[:email]
  product = params[:product]
  size = params[:size]
  unless email.nil? && product.nil? && size.nil?
    Gdoc.new( email, product, size ).send_data
  end
  redirect "/"
end

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

post "/fq-data" do
  
end

# post to
# https://script.google.com/a/macros/quincyapparel.com/s/AKfycbwmzRxlbyrs84ngOBDJOO6wfjZY-FiUFJ6HbmFuiYAZC4ljUV4/exec
# HTTParty.post("https://script.google.com/a/macros/quincyapparel.com/s/AKfycbwmzRxlbyrs84ngOBDJOO6wfjZY-FiUFJ6HbmFuiYAZC4ljUV4/exec",
#                :body => { email: "email", product: "product", size: "size" })
# HTTParty.get("https://script.google.com/a/macros/quincyapparel.com/s/AKfycbwmzRxlbyrs84ngOBDJOO6wfjZY-FiUFJ6HbmFuiYAZC4ljUV4/exec")
# puts HTTParty.get('http://whoismyrepresentative.com/whoismyrep.php?zip=55424').inspect
# Gdoc.new( "stuart@example.com", "ansley dress", "large" ).send_data
# options = { :body => { email: "stuart@example.com", product: "ansley dress", size: "large" }}
# self.class.post("https://script.google.com/a/macros/quincyapparel.com/s/AKfycbxSKEvKGze2BJiQE8_0iSeYrsmW20Mmg09ultyNgoTBD7rtAdI/exec", options)
# class Gdoc
#   include HTTParty
# end
# Gdoc.post("https://script.google.com/a/macros/quincyapparel.com/s/AKfycbxSKEvKGze2BJiQE8_0iSeYrsmW20Mmg09ultyNgoTBD7rtAdI/exec", options)





