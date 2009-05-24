require "integrity/project/notifiers"
require "integrity/project/push"

module Integrity
  class Project
    include DataMapper::Resource
    include Notifiers, Push

    property :id,         Serial
    property :name,       String,   :nullable => false
    property :permalink,  String
    property :uri,        URI,      :nullable => false, :length => 255
    property :branch,     String,   :nullable => false, :default => "master"
    property :command,    String,   :nullable => false, :length => 255, :default => "rake"
    property :public,     Boolean,  :default => true
    property :building,   Boolean,  :default => false

    timestamps :at

    default_scope(:default).update(:order => [:name.asc])

    has n, :commits, :class_name => "Integrity::Commit"
    has n, :notifiers, :class_name => "Integrity::Notifier"

    before :save, :set_permalink
    before :destroy, :delete_working_directory

    validates_is_unique :name

    def build(commit_identifier="HEAD")
      commit_identifier = head_of_remote_repo if commit_identifier == "HEAD"
      commit = find_or_create_commit_with_identifier(commit_identifier)

      Build.queue(commit)
    end

    def last_commit
      commits.first(:project_id => id, :order => [:committed_at.desc])
    end

    def previous_commits
      commits.all(:project_id => id, :order => [:committed_at.desc]).
        tap {|commits| commits.shift }
    end

    def status
      last_commit && last_commit.status
    end

    def human_readable_status
      last_commit && last_commit.human_readable_status
    end

    def public=(flag)
      attribute_set(:public, case flag
        when "1", "0" then flag == "1"
        else !!flag
      end)
    end

    private
      def find_or_create_commit_with_identifier(identifier)
        # We abuse +committed_at+ here setting it to Time.now because we use it
        # to sort (for last_commit and previous_commits). I don't like this
        # very much, but for now it's the only solution I can find.
        #
        # This also creates a dependency, as now we *always* have to update the
        # +committed_at+ field after building to ensure the date is correct :(
        #
        # This might also make your commit listings a little jumpy, if some
        # commits change place every time a build finishes =\
        commits.first_or_create({:identifier => identifier, :project_id => id},
          :committed_at => Time.now)
      end

      def head_of_remote_repo
        SCM.new(uri, branch).head
      end

      def set_permalink
        attribute_set(:permalink, (name || "").downcase.
          gsub(/'s/, "s").
          gsub(/&/, "and").
          gsub(/[^a-z0-9]+/, "-").
          gsub(/-*$/, ""))
      end

      def delete_working_directory
        commits.destroy!
        ProjectBuilder.delete_working_directory(self)
      rescue SCM::SCMUnknownError => error
        Integrity.log "Problem while trying to deleting code: #{error}"
      end
  end
end
