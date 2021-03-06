require 'spec_helper'
require 'support/active_record'

describe Commit do
  include Support::ActiveRecord

  let(:commit) { Commit.new(:commit => '12345678') }

  describe 'config_url' do
    it 'returns the raw url to the .travis.yml file on github' do
      commit.repository = Repository.new(:owner_name => 'travis-ci', :name => 'travis-ci')
      commit.config_url.should == 'https://raw.github.com/travis-ci/travis-ci/12345678/.travis.yml'
    end
  end

  describe 'skipped?' do
    it 'returns true when the commit message contains [ci skip]' do
      commit.message = 'lets party like its 1999 [ci skip]'
      commit.skipped?.should be_true
    end

    it 'returns true when the commit message contains [CI skip]' do
      commit.message = 'lets party like its 1999 [CI skip]'
      commit.skipped?.should be_true
    end

    it 'returns true when the commit message contains [ci:skip]' do
      commit.message = 'lets party like its 1999 [ci:skip]'
      commit.skipped?.should be_true
    end

    it 'returns false when the commit message contains [ci unknown-command]' do
      commit.message = 'lets party like its 1999 [ci unknown-command]'
      commit.skipped?.should be_false
    end
  end

  describe 'github_pages?' do
    it 'returns true for a branch named gh-pages' do
      commit.ref = 'refs/heads/gh-pages'
      commit.github_pages?.should be_true
    end

    it 'returns true for a branch named gh_pages' do
      commit.ref = 'refs/heads/gh_pages'
      commit.github_pages?.should be_true
    end

    it 'returns false for a branch named master' do
      commit.ref = 'refs/heads/master'
      commit.github_pages?.should be_false
    end
  end

  describe 'pull_request?' do
    it 'is false for a nil ref' do
      commit.ref = nil
      commit.pull_request?.should be_false
    end

    it 'is false for a ref named ref/branch/master' do
      commit.ref = 'refs/branch/master'
      commit.pull_request?.should be_false
    end

    it 'is false for a ref named ref/pull/180/head' do
      commit.ref = 'refs/pull/180/head'
      commit.pull_request?.should be_false
    end

    it 'is true for a ref named ref/pull/180/merge' do
      commit.ref = 'refs/pull/180/merge'
      commit.pull_request?.should be_true
    end
  end
end
