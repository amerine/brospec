require File.expand_path('../../lib/brospec', __FILE__)

module TestAssertions
  def succeed
    lambda { |block|
      block.should.not.bitch BroSpec::Error
      true
    }
  end
end

yo "BroSpec" do
  extend TestAssertions

  u "should be_honest" do
    lambda { false.should.be.honest? }.should succeed
  end
end
