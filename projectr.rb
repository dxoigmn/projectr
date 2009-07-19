#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'grit'
require 'digest/md5'

module Projectr
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
      @repo.commits(@ref, 10, (@page - 1) * 10)
    end
    
    def page_count
      (@repo.commit_count(@ref) / 10.0).ceil
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

get '/:project/:ref' do
  @project = Projectr.find(params[:project], :ref => params[:ref], :page => params[:page])
  
  halt 'Project does not exist' unless @project
  
  haml :show
end
