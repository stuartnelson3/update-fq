require 'bundler'
require 'httparty'
require 'omniauth-shopify'
require 'sinatra'
require 'thin'

#ShopifyAPI::Session.setup({:api_key => 025e3f7239cb03756f62067cc20c7e43, :secret => 6cec5463b7c5bb8213ed69bb6de64290})

use Rack::Session::Cookie
use OmniAuth::Strategies::Shopify, ENV['025e3f7239cb03756f62067cc20c7e43'], ENV['6cec5463b7c5bb8213ed69bb6de64290']

# customer = ShopifyAPI::Customer.find(89266874)

# 89266874 is the id for stuart@quincyapparel.com
# id = 89266874

class UpdateFQ
  include HTTParty
  base_uri "https://quincy.myshopify.com"
  
  def self.update_fq(id,bust)
    hash = { :metafield => { :namespace => "customer", :key => "fq_bust", :value => "#{bust}", :value_type => "string" }}
    post("/admin/customers/#{id}/metafields.json", :query => hash)
  end
end

get "/" do
  <<-HTML
    <ul>
      <li><a href='/auth/shopify'>Sign in with Shopify</a></li>
    </ul>
    HTML
end

get "/index" do
  erb :index
end

post "/post" do
  id = params[:customer_id]
  bust = params[:bust]
  length = params[:length]
  waist = params[:waist]
  list = [bust, length, waist]
  
  hash = { :metafield => { :namespace => "customer", :key => "fq_bust", :value => "#{bust}", :value_type => "string" }}
  post("https://quincy.myshopify.com/admin/customers/#{id}/metafields.json", :query => hash)
  
  # hash = { :metafield => { :namespace => "customer", :key => "fq_length", :value => "#{length}", :value_type => "string" }}
  # post("https://quincy.myshopify.com/admin/customers/#{id}/metafields.json")
  # 
  # hash = { :metafield => { :namespace => "customer", :key => "fq_waist", :value => "#{waist}", :value_type => "string" }}
  # post("https://quincy.myshopify.com/admin/customers/#{id}/metafields.json")

  erb :result
end

#SHOPIFY_KEY="025e3f7239cb03756f62067cc20c7e43" SHOPIFY_SECRET="6cec5463b7c5bb8213ed69bb6de64290" ruby customer_fq_update.rb




#   $meta_data = array('metafield'=>array('namespace'=>'customer','key'=>'fq_bust','value'=> "$fq_bust", 'value_type'=>'string'));
# } else if ($i==1) {
#   $meta_data = array('metafield'=>array('namespace'=>'customer','key'=>'fq_length','value'=> "$fq_length", 'value_type'=>'string'));
# } else if ($i==2) {
#   $meta_data = array('metafield'=>array('namespace'=>'customer','key'=>'fq_waist','value'=> "$fq_waist", 'value_type'=>'string'));
# } else if ($i==3) {
#   $meta_data = array('metafield'=>array('namespace'=>'customer','key'=>'fq_data','value'=> "$fq_data", 'value_type'=>'string'));
















