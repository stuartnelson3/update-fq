require 'bundler'
require 'shotgun'
require 'sinatra'
require 'thin'
require 'shopify_api'

# Get access to Shopify API
ShopifyAPI::Base.site = "https://63853221c8f1fae9b9b25345b10ec9c8:5ac79471d7d5407d353e015717d6a49b@quincy.myshopify.com/admin"

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










