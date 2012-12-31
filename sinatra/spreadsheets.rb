module HTTParty; extend ActiveSupport::Concern; end
module DataToSpreadsheet
  extend ActiveSupport::Concern
  include HTTParty
  
  def send_data_to_spreadsheet
    self.class.post(base_url + url, post_data_hash)
  end
  
  private
  def post_data_hash
    hash = {}
    instance_variables.each do |var| 
      hash[var[1..-1].to_sym] = instance_variable_get(var) 
    end
    { :body => hash }
  end
end
class Spreadsheet
  def base_url
    "https://script.google.com/a/macros/quincyapparel.com/s"
  end
end
class Notify < Spreadsheet
  include DataToSpreadsheet
  
  def initialize(email, product, size, sku)
    @email = email
    @product = product
    @size = size
    @sku = sku
  end
  def url; "/AKfycbxSKEvKGze2BJiQE8_0iSeYrsmW20Mmg09ultyNgoTBD7rtAdI/exec"; end 
end

class GiftCard < Spreadsheet
  include DataToSpreadsheet
  
  def initialize(gift_card_giver, gift_card_giver_email, gift_card_receiver, gift_card_receiver_email, deliver_date, amount, message)
    @gifter_name = gift_card_giver
    @gifter_email = gift_card_giver_email
    @giftee_name = gift_card_receiver
    @giftee_email = gift_card_receiver_email
    @deliver_date = deliver_date
    @amount = amount
    @message = message
  end
  def url; "/AKfycbwUnFlEF2hZxQaR6Wq5ZqCvEdsn-4gPz21s_inYnNe951ejNgot/exec"; end
end

class NewUser < Spreadsheet
  include DataToSpreadsheet
  
  def initialize(email, name)
    @email = email
    @name = name
  end
  def url; "/AKfycbySel7EM9VwIP-JXkeiO4JUD4_UeEU3OeotAe2o3LlbyshsX76X/exec"; end
end

class Referral < Spreadsheet
  include DataToSpreadsheet
  include QuincyMailer

  def initialize(first_name, last_name, email)
    @first_name = first_name
    @last_name = last_name
    @email = email
  end
  def url; "/AKfycbz1UviZnwGJAWN4L1r8X-KzBnNc6A9tTiYLX8ZwUusKDZ8HcLyN/exec"; end
end