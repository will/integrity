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
        git_uri = to_git_uri(uri)
        git_uri.working_tree_path.should == "path-to-repo"
        git_uri.should_not be_github
      end

      it "should not recognize #{uri} as a github URI" do
        to_git_uri(uri).should_not be_github
      end

      specify "github username for #{uri} should be nil" do
        to_git_uri(uri).bypass.github_username.should be_nil
      end

      specify "github repository for #{uri} should be nil" do
        to_git_uri(uri).bypass.github_repository.should be_nil
      end
    end

    it 'should be capable of converting itselfs to a string' do
      to_git_uri('git://example.org/repo.git').to_s.should == 'git://example.org/repo.git'
    end

    describe 'with a github uri' do
      uris = [
        'git://github.com/foca/integrity.git',
        'git://github.com/foca/integrity',
        'git@github.com:foca/integrity.git',
        'git@github.com:foca/integrity'
      ]

      uris.each do |uri|
        it "should recognize #{uri} as a github URI" do
          to_git_uri(uri).should be_github
        end

        it 'should give an URI pointing to a commit on github' do
          sha1 = 'ff6e583f69ea0d1422d2df3434df0926a242d2a3'
          to_git_uri(uri).github_commit_uri(sha1).should ==
            'http://github.com/foca/integrity/commit/ff6e583f69ea0d1422d2df3434df0926a242d2a3'
        end

        it 'should give the github username' do
          to_git_uri(uri).bypass.github_username.should == 'foca'
        end

        it 'should give the github repository' do
          to_git_uri(uri).bypass.github_repository.should == 'integrity'
        end
      end
    end
  end
end
