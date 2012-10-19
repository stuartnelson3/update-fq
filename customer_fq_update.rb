require 'bundler'
# for development
# require 'shotgun'
require 'sinatra'
require 'thin'
require 'shopify_api'
require 'httparty'

# Get access to Shopify API
ShopifyAPI::Base.site = "https://63853221c8f1fae9b9b25345b10ec9c8:5ac79471d7d5407d353e015717d6a49b@quincy.myshopify.com/admin"

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
  erb :index
end

post "/data" do
  id = params[:id]
  @customer = ShopifyAPI::Customer.find(id)
  @name = @customer.first_name + " " + @customer.last_name
  @email = @customer.email
  @bust = @customer.metafields[0].value unless @customer.metafields[0].nil?
  @quiz_results = @customer.metafields[1].value unless @customer.metafields[1].nil?
  @length = @customer.metafields[2].value unless @customer.metafields[2].nil?
  @waist = @customer.metafields[3].value unless @customer.metafields[3].nil?
  erb :data
end

post "/back-in-stock" do
  email = params[:email]
  product = params[:product]
  size = params[:size]
  Gdoc.new( email, product, size ).send_data
end

# post to
# https://script.google.com/a/macros/quincyapparel.com/s/AKfycbwmzRxlbyrs84ngOBDJOO6wfjZY-FiUFJ6HbmFuiYAZC4ljUV4/exec
# HTTParty.post("https://script.google.com/a/macros/quincyapparel.com/s/AKfycbwmzRxlbyrs84ngOBDJOO6wfjZY-FiUFJ6HbmFuiYAZC4ljUV4/exec",
#                :body => { email: "email", product: "product", size: "size" })
# HTTParty.get("https://script.google.com/a/macros/quincyapparel.com/s/AKfycbwmzRxlbyrs84ngOBDJOO6wfjZY-FiUFJ6HbmFuiYAZC4ljUV4/exec")
# puts HTTParty.get('http://whoismyrepresentative.com/whoismyrep.php?zip=55424').inspect








