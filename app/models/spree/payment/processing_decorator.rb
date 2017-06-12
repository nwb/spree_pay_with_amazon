##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
Spree::Payment::Processing.class_eval do
  def close!
    gateway_action(source, :close, :close)
  end

  def cancel!
    if payment_method.type=='Spree::Gateway::Amazon'
      #byebug
      if refunds.any?
        response = payment_method.credit((order.total-refunds.map(&:amount).sum)*100,nil,  order_id: (order.number+  '-' + Digest::MD5.hexdigest(number+Time.new().to_s).truncate(20, omission: '')) )
      else
        response = payment_method.void(response_code,  order_id: (order.number+  '-' + Digest::MD5.hexdigest(number+Time.new().to_s).truncate(20, omission: '')) )
      end
      if response.success? #!response.params["ErrorResponse"]
        self.send("void!")
      else
        self.send(failure_state)
        gateway_error(response)
      end
      #handle_response(response, :void, :failure)
    else
      response = payment_method.cancel(response_code)
      handle_response(response, :void, :failure)
    end
  end
end