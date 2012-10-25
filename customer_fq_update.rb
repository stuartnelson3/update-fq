require 'bundler'
# for development
# require 'shotgun'
require 'sinatra'
require 'thin'
require 'shopify_api'
require 'httparty'
require 'gmail'
require 'google_drive'

# Get access to Shopify API
ShopifyAPI::Base.site = "https://63853221c8f1fae9b9b25345b10ec9c8:5ac79471d7d5407d353e015717d6a49b@quincy.myshopify.com/admin"

# Log into GoogleDrive
session = GoogleDrive.login("stuart@quincyapparel.com", "Von9vAG6")

# log into gmail
gmail = Gmail.connect("info@quincyapparel.com", "L0nd0n10")

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

get "/back-in-stock" do
  email = params[:email]
  product = params[:product]
  size = params[:size]
  Gdoc.new( email, product, size ).send_data
  return "1"
end

post "/customer-followup" do
  
  start = params[:start].to_i
  finish = params[:end].to_i
  # array of columns that gdrive gem pulls info from
  followup = (start..finish).to_a
  
  # First worksheet of
  # https://docs.google.com/spreadsheet/ccc?key=0Auto3l0QT211dFJGWmlDYzZXRG9EMzE2UFE1UHRhM0E
  ws = session.spreadsheet_by_key("0Auto3l0QT211dFJGWmlDYzZXRG9EMzE2UFE1UHRhM0E").worksheets[0]

  # send email
  followup.each do |user|
    unless ws[user, 4] == "?"
      # pulls email address entered in row from followup array, column 2
      email = ws[user, 2]
      # pulls name address entered in row from followup array, column 3
      name = ws[user, 3]
      gmail.deliver do
        to email
        subject "Your Quincy order"
        text_part do
        body "Hi #{name},

  We just wanted to check in and make sure you received your recent Quincy order.

  We would love to hear back about how you are liking your recent purchase.

  Thanks for your feedback and support!

  Xo,

  The Quincy Team"
        end
      end
      # writes "?" to column 4 in row corresponding to the user
      ws[user, 4] = "?"
      # saves changes to gdoc
      ws.save()
      puts "Sent email to #{ws[user, 2]}"
      sleep 3
    end
  end
  return "Done"
end

post "/review-followup" do
  
  start = params[:start].to_i
  finish = params[:end].to_i
  # array of columns that gdrive gem pulls info from
  followup = (start..finish).to_a
  
  ws = session.spreadsheet_by_key("0Auto3l0QT211dEJNSDZhX0FFSXUxMUFYYW9jT3Y3Y1E").worksheets[0]

  # hash to take product names and get back urls
  @product_urls = Hash.new
  @product_urls[:ansleydress] = 100645392
  @product_urls[:elliottblazer] = 100645402
  @product_urls[:elliottcigarettepant] = 100645426
  @product_urls[:chloeshirt] = 100645416
  @product_urls[:rileycigarettepant] = 100645428
  @product_urls[:kennedyblouse] = 100645414
  @product_urls[:fionablouse] = 100645420
  @product_urls[:janejacket] = 100645406
  @product_urls[:rileypencilskirt] = 100645438
  @product_urls[:rileyblazer] = 100646236
  @product_urls[:rileysheathdress] = 100645398
  @product_urls[:emmajacket] = 100645412
  @product_urls[:elliottpencilskirt] = 100645434
  @product_urls[:chelseablazer] = 100645404
  @product_urls[:elliottsheathdress] = 100645396
  @product_urls[:elliottsheathskirt] = 100645430
  @product_urls[:elliotttrouser] = 100645424

  # interpolate ids into url
  def review_link(id)
    "http://quincy.myshopify.com/apps/powerreviews/review.html?pr_page_id=#{id}&pr_source=email"
  end

  # change email template slightly depending
  # on if customer bought one or more items
  def single_or_plural(array)
    array.length > 1 ? "pieces you ordered" : array.first.capitalize
  end

  # returns elements name along with link
  def generate_review_links(array)
    a = ""
    array.each do |element|
      # turn element into a symbol
      symbol = turn_to_symbol(element)
      # get the id for the corresponding value in product_url hash
      id = @product_urls[symbol]
      a += "<p>#{element.capitalize}:</p><a href='#{review_link(id)}'>#{review_link(id)}</a>"
    end
    return a
  end

  # removes any whitespace,
  # and changes string to symbol
  def turn_to_symbol(string)
    string.gsub(/\s+/, "").to_sym
  end

  followup.each do |user|
    unless ws[user, 4] == "Yes"
      # gives list of products
      products_bought = ws[user, 3].downcase
      # creates array, gets rid of leading and trailing whitespace
      product_array = products_bought.split(",").each {|e| e.strip!}
      # doesn't work to interpolate generate_review_links method,
      # but just inserting the output does
      links = generate_review_links(product_array)
      gmail.deliver do
        # pulls name address entered in row from followup array, column 1
        name = ws[user, 1]
        # pulls email address entered in row from followup array, column 2
        email = ws[user, 2]
        # start email
        to email
        subject "Will you do us a small favor?"
        html_part do
          content_type "text/html; charset=UTF-8"
          body "<p>#{name},</p>
                <p>We're so glad to hear that you love the #{single_or_plural(product_array)}.&nbsp;
                We'd really appreciate it if you could take 5 minutes to write a review for our website.&nbsp;
                Since we're a new brand, these reviews are incredibly helpful to customers.</p>
                <p>Here's a verified buyer link for the #{single_or_plural(product_array)}:</p>
                #{links}
                <p>Thank you so much for being one of our first customers!</p>
                <p>&mdash; The Quincy team</p>
          "
        end
      end
      ws[user, 4] = "Yes"
      ws.save
      sleep 3
    end
  end
  return "Done"
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





