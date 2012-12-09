require "sinatra/base"

module QuincyMailer
  def send_to_quincy
    gmail = Gmail.connect("info@quincyapparel.com", "L0nd0n10")
    receiving_address = "accounts@quincyapparel.com"
    info = hash_info

    gmail.deliver do
      to receiving_address
      subject "Referral program CODE request"
      html_part do
        content_type "text/html; charset=UTF-8"
        body "<p>Hi Quincy,</p>
              <p>You have a new member for your referral program!&nbsp;
              Here is their info:</p>
              #{info}
              <p>&mdash; Q-bot</p>
        "
      end
    end
  end

  private
    def information_for_email
      hash = {}
      instance_variables.each do |var| 
        hash[var[1..-1].to_sym] = instance_variable_get(var) 
      end
      hash.delete :url
      hash
    end
    def hash_info
      a = ""
      information_for_email.each do |k,v|
        a += "<p>#{k.to_s.gsub("_", " ").capitalize}: #{v}</p>"
      end
      a
    end
end

module Sinatra
  module Emails

    def google_spreadsheet(key)
      session = GoogleDrive.login("stuart@quincyapparel.com", "Von9vAG6")
      session.spreadsheet_by_key(key).worksheets[0]
    end

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
      @product_urls[:charliecroppedjacket] = 109310476
      @product_urls[:heatherblazer] = 109310474
      @product_urls[:jaclyndress] = 109310478
      
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

    def mail_users(user, reason)
      # log in to gmail
      gmail = Gmail.connect("info@quincyapparel.com", "L0nd0n10")
      # work with correct spreadsheet
      ws = google_spreadsheet reason == "reviews" ? "0Auto3l0QT211dEJNSDZhX0FFSXUxMUFYYW9jT3Y3Y1E" : "0Auto3l0QT211dFJGWmlDYzZXRG9EMzE2UFE1UHRhM0E"
      if reason == "reviews"
        unless ws[user, 4] == "Yes"
          # gives list of products
          products_bought = ws[user, 3].downcase
          # creates array, gets rid of leading and trailing whitespace
          product_array = products_bought.split(",").each {|e| e.strip!}
          # doesn't work to interpolate methods,
          # but just inserting the output does
          review_links = generate_review_links(product_array)
          item_number = single_or_plural(product_array)
          # pulls name address entered in row from followup array, column 1
          name = ws[user, 1]
          # pulls email address entered in row from followup array, column 2
          email = ws[user, 2]
          # start email
          gmail.deliver do
            to email
            subject "Will you do us a small favor?"
            html_part do
              content_type "text/html; charset=UTF-8"
              body "<p>#{name},</p>
                    <p>We're so glad to hear that you love the #{item_number}.&nbsp;
                    We'd really appreciate it if you could take 5 minutes to write a review for our website.&nbsp;
                    Since we're a new brand, these reviews are incredibly helpful to customers.</p>
                    <p>Here's a verified buyer link for the #{item_number}:</p>
                    #{review_links}
                    <p>Thank you so much for being one of our first customers!</p>
                    <p>&mdash; The Quincy team</p>
              "
            end
          end
          ws[user, 4] = "Yes"
          ws.save
          sleep 3
          puts "sent email to #{ws[user, 2]}"
        end
      elsif reason == "customers"
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
          ws.save
          puts "Sent email to #{ws[user, 2]}"
          sleep 3
        end
      end
    end
 
  end
  
  helpers Emails, QuincyMailer
end