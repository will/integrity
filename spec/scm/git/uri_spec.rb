require File.dirname(__FILE__) +  '/../../spec_helper'

module Integrity
  describe SCM::Git::URI do
    def to_git_uri(string)
      SCM::Git::URI.new(string)
    end
    
    uris = [
      "rsync://host.xz/path/to/repo.git/",
      "rsync://host.xz/path/to/repo.git",
      "rsync://host.xz/path/to/repo.gi",
      "http://host.xz/path/to/repo.git/",
      "https://host.xz/path/to/repo.git/",
      "git://host.xz/path/to/repo.git/",
      "git://host.xz/~user/path/to/repo.git/",
      "ssh://[user@]host.xz[:port]/path/to/repo.git/",
      "ssh://[user@]host.xz/path/to/repo.git/",
      "ssh://[user@]host.xz/~user/path/to/repo.git/",
      "ssh://[user@]host.xz/~/path/to/repo.git",
      "host.xz:/path/to/repo.git/",
      "host.xz:~user/path/to/repo.git/",
      "host.xz:path/to/repo.git",
      "user@host.xz:/path/to/repo.git/",
      "user@host.xz:~user/path/to/repo.git/",
      "user@host.xz:path/to/repo.git",
      "user@host.xz:path/to/repo",
      "user@host.xz:path/to/repo.a_git"            
    ]
    
    uris.each do |uri|
      it "should parse the URI #{uri}" do
        git_url = to_git_uri(uri)
        git_url.working_tree_path.should == "path-to-repo"
      end
    end

    it 'should converts itselfs to a string' do
      to_git_uri('git://example.org/repo.git').to_s.should == 'git://example.org/repo.git'
    end

    it 'should recognize github URIs' do
      to_git_uri('git://github.com/foca/integrity').should be_github
      to_git_uri('git@github.com:foca/integrity').should be_github
    end

    specify 'github username should be nil for non-github uris' do
      to_git_uri('git://example.org/repo.git').github_username.should be_nil
    end

    specify 'github repository should be nil for non-github uris' do
      to_git_uri('git://example.org/repo.git').github_repository.should be_nil
    end

    describe 'with a github uri' do
      it 'should parse the github username' do
        to_git_uri('git://github.com/foca/integrity').github_username.should == 'foca'
      end

      it 'should parse the github repository' do
        to_git_uri('git://github.com/foca/integrity').github_repository.should == 'integrity'
      end
    end
  end
end
