# LibertyReserve

class LibertyTransaction
  attr_accessor :date,:payer_name,:payee_name,:amount,:fee,:payer,:payee,:receipt_id
end  

class LibertyReserve
  
  def initialize api_name, api_pwd, account_id
    @api_name = api_name
    @api_pwd=api_pwd
    @account_id = account_id
  end  
  
  
  def history(start_date=nil,end_date=nil, request_id='123456789') 
    
   require "rexml/document"
   token = Time.now.utc.strftime("#{@api_pwd}:%Y%m%d:%H") 
   @token = (Digest::SHA256.hexdigest token)
  
   page = 1
   transactions=[]
   begin
     http = Net::HTTP.new('api.libertyreserve.com',443)
     http.use_ssl = true
            
     xml= (self.history_request(page, start_date, end_date, request_id))
     txt_xml = (xml.to_s).gsub('<to_s/>','')
     response, data = http.get('/xml/history.aspx?req='+CGI::escape(txt_xml.gsub('<inspect/>','')), nil)   
     
     doc= REXML::Document.new data
     size=0
     transactions+=doc.elements.collect("HistoryResponse/Receipt/") do |e| 
       size+=1
       lt =LibertyTransaction.new
       lt.receipt_id = e.elements['ReceiptId'].text
       lt.date= DateTime.strptime(e.elements['Date'].text,'%Y-%d-%m %H:%M:%S')
       lt.payer_name= e.elements['PayerName'].text
       lt.payee_name= e.elements['PayeeName'].text
       lt.payer=e.elements['Transfer'].elements['Payer'].text
       lt.payee=e.elements['Transfer'].elements['Payee'].text
       lt.amount= e.elements['Amount'].text
       lt.fee= e.elements['Fee'].text
       lt
     end
     page+=1
    end while size!=0
    transactions      
  end
  
  protected  
  
  def history_request page,start_date=nil,end_date=nil, request_id='123456789'
     xml=  Builder::XmlMarkup.new( :indent => 2 )
     xml.HistoryRequest  :id=>request_id do
        xml.Auth do |auth|
          auth.ApiName @api_name
          auth.Token @token
        end
        xml.History do |history|
          history.AccountId @account_id
          history.Pager do |pager|
            pager.PageSize 100
            pager.PageNumber page
          end
        end
     end
     xml
  end
  
end  