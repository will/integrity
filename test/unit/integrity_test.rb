require File.dirname(__FILE__) + "/../helpers"

class IntegrityTest < Test::Unit::TestCase
  describe "#new" do
    setup do
      stub(DataMapper).setup { nil }
      @config_file = File.dirname(__FILE__) + "/../../config/config.sample.yml"
    end

    it "doesn't require any argument" do
      Integrity.new

      assert_equal Integrity.default_configuration[:log],
        Integrity.config[:log]
    end

    it "loads configuration from a file" do
      Integrity.new(@config_file)

      assert_equal "http://integrity.domain.tld", Integrity.config[:base_uri]
      assert_equal "/path/to/scm/exports",        Integrity.config[:export_directory]
    end

    it "takes configuration as an hash" do
      Integrity.new(:base_uri => "http://foo.org")

      assert_equal "http://foo.org", Integrity.config[:base_uri]
    end
  end

  specify "config is just a hash" do
    Integrity.config[:foo] = "bar"
    Integrity.config[:foo].should == "bar"
  end
end
