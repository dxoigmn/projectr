#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'grit'
require 'digest/md5'
require 'json'

module Projectr
  class Commit
    attr_reader :project, :commit
    
    def initialize(project, commit)
      @project  = project
      @commit   = commit
    end
    
    def id
      "/#{Rack::Utils.escape(project.name)}/#{Rack::Utils.escape(commit.sha)}"
    end
    
    def sha
      commit.sha
    end
    
    def author_gravatar
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(commit.author.email.downcase)}.jpg?d=identicon"
    end
    
    def author_name
      commit.author.name
    end
    
    def committer_name
      commit.committer.name
    end
    
    def committer_gravatar
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(commit.committer.email.downcase)}.jpg?d=identicon"
    end
    
    def authored_date
      commit.authored_date
    end
    
    def committed_date
      commit.committed_date
    end
    
    def message
      commit.message
    end
    
    def by_author?
      commit.author.email.downcase == commit.committer.email.downcase
    end
    
    def to_json(*a)
      {
        :id => id,
        :sha => sha,
        :author_gravatar => author_gravatar,
        :author_name => author_name,
        :committer_name => committer_name,
        :committer_gravatar => committer_gravatar,
        :authored_date => authored_date,
        :committed_date => committed_date,
        :message => message,
        :by_author? => by_author?
      }.to_json(*a)
    end
  end
  
  class Project
    attr_reader :path, :name, :repo, :ref, :page
    
    def initialize(path, options = {})
      @path = path
      @name = File.basename(path)
      @repo = Grit::Repo.new(path)
      @ref  = options[:ref] || @repo.heads.first.name
      @page = (options[:page] || 1).to_i
    end
    
    def commits
      @repo.commits(@ref, 25, (@page - 1) * 25).map { |commit| Commit.new(self, commit) }
    end
    
    def page_count
      (@repo.commit_count(@ref) / 25.0).ceil
    end
    
    def branches
      @repo.branches
    end
    
    def tags
      @repo.tags
    end
  end
  
  def self.all
    Dir[PATH].map { |path| Projectr::Project.new(path) }
  end
  
  def self.find(name, options = {})
    path = File.join(File.dirname(PATH), name)
    
    return nil unless File.directory?(path)
    
    Project.new(path, options)
  end
end

configure do
  config = YAML.load(IO.read(File.join(File.dirname(__FILE__), 'projectr.yml')))[:projectr]
  
  fail 'Couldn\'t find configuration.' unless config
  
  Projectr::PATH = config[:path]
end

get '/' do
  @projects = Projectr.all
  
  haml :index
end

get '/:project' do
  @project = Projectr.find(params[:project], :page => params[:page])
  
  halt 'Project does not exist' unless @project
  
  haml :show
end

get '/:project/:ref.js' do
  @project = Projectr.find(params[:project], :ref => params[:ref])
  
  halt 'Project does not exist' unless @project
  
  content_type :json
  @project.commits.to_json
end

get '/:project/:ref' do
  @project = Projectr.find(params[:project], :ref => params[:ref], :page => params[:page])
  
  halt 'Project does not exist' unless @project
  
  haml :show
end

