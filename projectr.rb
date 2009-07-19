#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'grit'
require 'digest/md5'

module Projectr
  class Project
    attr_reader :path, :name, :repo, :ref
    
    def initialize(path, options = {})
      @path = path
      @name = File.basename(path)
      @repo = Grit::Repo.new(path)
      @ref  = options[:ref] || @repo.heads.first.name
    end
    
    def commits
      @repo.commits(@ref)
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
  @project = Projectr.find(params[:project])
  
  halt 'Project does not exist' unless @project
  
  haml :show
end

get '/:project/:ref' do
  @project = Projectr.find(params[:project], :ref => params[:ref])
  
  halt 'Project does not exist' unless @project
  
  haml :show
end
