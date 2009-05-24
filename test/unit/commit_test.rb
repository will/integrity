require File.dirname(__FILE__) + '/../helpers'

class CommitTest < Test::Unit::TestCase
  specify "fixture is valid and can be saved" do
    lambda do
      commit = Commit.gen
      commit.save

      commit.should be_valid
    end.should change(Commit, :count).by(1)
  end

  describe "Properties" do
    before(:each) do
      @commit = Commit.generate(:identifier => "658ba96cb0235e82ee720510c049883955200fa9",
                                :author => "Nicolás Sanguinetti <contacto@nicolassanguinetti.info>")
    end

    it "has a commit identifier" do
      @commit.identifier.should be("658ba96cb0235e82ee720510c049883955200fa9")
    end

    it "has a short commit identifier" do
      @commit.short_identifier.should == "658ba96"

      @commit.identifier = "402"
      @commit.short_identifier.should == "402"
    end

    it "has a commit author" do
      commit = Commit.gen(:author => "Nicolás Sanguinetti <contacto@nicolassanguinetti.info>")
      commit.author.name.should == "Nicolás Sanguinetti"
      commit.author.email.should == "contacto@nicolassanguinetti.info"
      commit.author.full.should == "Nicolás Sanguinetti <contacto@nicolassanguinetti.info>"

      Commit.gen(:author => nil).author.to_s.should =~ /not loaded/
    end

    it "raises ArgumentError with invalid author" do
      lambda { Commit.gen(:author => "foo") }.should raise_error(ArgumentError)
    end

    it "has a commit message" do
      commit = Commit.gen(:message => "This commit rocks")
      commit.message.should == "This commit rocks"

      Commit.gen(:message => nil).message.should =~ /not loaded/
    end

    it "has a commit date" do
      commit = Commit.gen(:committed_at => Time.utc(2008, 10, 12, 14, 18, 20))
      commit.committed_at.to_s.should == "2008-10-12T14:18:20+00:00"
    end

    it "has a human readable status" do
      commit = Commit.gen(:successful, :identifier => "658ba96cb0235e82ee720510c049883955200fa9")
      commit.human_readable_status.should be("Built 658ba96 successfully")

      commit = Commit.gen(:failed, :identifier => "658ba96cb0235e82ee720510c049883955200fa9")
      commit.human_readable_status.should be("Built 658ba96 and failed")

      commit = Commit.gen(:pending, :identifier => "658ba96cb0235e82ee720510c049883955200fa9")
      commit.human_readable_status.should be("658ba96 hasn't been built yet")
    end
  end
end
