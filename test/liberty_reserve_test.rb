require 'test_helper'

class LibertyReserveTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def setup
    @lr = LibertyReserve.new('XXX','XXX','XXX')
    @h= @lr.history
  end  
  
  def test_history_content
    assert_not_nil @h.first.payer_name
  end
  
  def test_history_size
    assert_equal @h.size,50
  end
  
  def teardown
     
  end
end
