# LibertyReserve

class LibertyTransaction
  attr_accessor :date,:payer_name,:payee_name,:amount,:fee
end  

class LibertyReserve
  def initialize api_name, api_pwd, account_id
    @api_name = api_name
    @api_pwd=api_pwd
    @account_id = account_id
  end  
  
  def history(start_date=nil,end_date=nil, request_id='123456789') 
   token = Time.now.utc.strftime("#{@api_pwd}:%Y%m%d:%H") 
   @token = (Digest::SHA256.hexdigest token)
   xml=  Builder::XmlMarkup.new( :indent => 2 )
   xml.HistoryRequest  :id=>request_id do
      xml.Auth do |auth|
        auth.ApiName @api_name
        auth.Token @token       
      end
      xml.History do |history|
        history.AccountId @account_id
      end
   end    

   http = Net::HTTP.new('api.libertyreserve.com',443)
   http.use_ssl = true
   txt_xml = (xml.to_s).gsub('<to_s/>','')
   response, data = http.get('/xml/history.aspx?req='+CGI::escape(txt_xml.gsub('<inspect/>','')), nil)   
   doc= REXML::Document.new data
   doc.elements.collect("HistoryResponse/Receipt/") do |e| 
    lt =LibertyTransaction.new
    lt.date= e.elements['Date']
    lt.payer_name= e.elements['PayerName']
    lt.payee_name= e.elements['PayeeName']
    lt.amount= e.elements['Amount']
    lt.fee= e.elements['Fee']
    lt
   end   
  end
end  