require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Order do
  before(:each) do
    @creditcard_payment = mock_model(CreditcardPayment, :null_object => true)
    @order = Order.new(:creditcard_payment => @creditcard_payment, :checkout_complete => true)
    add_stubs(@order, :save => true)
  end

  describe "capture" do
    it "should capture the creditcard_payment" do
      @order.state = 'authorized'
      @creditcard_payment.should_receive(:capture)
      @order.capture
    end
  end

  describe "cancel" do    
    before(:each) { OrderMailer.stub!(:deliver_cancel).with(any_args) }
    
    %w{authorized captured}.each do |state|
      describe "from #{state} state" do
        it "should cancel the creditcard_payment" do
          @order.state = state
          @inventory_unit.stub!(:state).and_return('sold')
          @creditcard_payment.should_receive(:void)
          @order.cancel
        end
      end
    end
  end

  describe "return" do
    it "should cancel the creditcard_payment" do
      @order.state = 'shipped'
      @inventory_unit.stub!(:state).and_return('shipped')
      @creditcard_payment.should_receive(:void)
      @order.return
    end
  end
end