require 'spec_helper'
require 'rest_spec_helper'
require 'rhc/commands/app'
require 'rhc/config'

describe RHC::Commands::App do
  before(:each) do
    FakeFS.activate!
    RHC::Config.set_defaults
    instance = RHC::Commands::App.new
    RHC::Commands::App.stub(:new) do
      instance.stub(:git_config_get) { "" }
      instance.stub(:git_config_set) { "" }
      instance.stub(:git_clone_repo) do |git_url, repo_dir|
        raise RHC::GitException, "Error in git clone" if repo_dir == "giterrorapp"
        Dir::mkdir(repo_dir)
      end
      instance.stub(:host_exist?) do |host|
        return false if host.match("dnserror")
        true
      end
      instance
    end
  end

  after(:each) do
    FakeFS::FileSystem.clear
    FakeFS.deactivate!
  end

  describe 'app create' do
    let(:arguments) { ['app', 'create', 'app1', 'mock_standalone_cart-1', '--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }

    context 'when run' do
      before(:each) do
        @rc = MockRestClient.new
        domain = @rc.add_domain("mockdomain")
      end
      it { expect { run }.should exit_with_code(0) }
      it { run_output.should match("Success") }
    end
  end

  describe 'app create no cart found error' do
    let(:arguments) { ['app', 'create', 'app1', 'nomatch_cart', '--trace', '--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }

    context 'when run' do
      before(:each) do
        @rc = MockRestClient.new
        domain = @rc.add_domain("mockdomain")
      end
      it { expect { run }.should raise_error(RHC::CartridgeNotFoundException) }
    end
  end

  describe 'app create too many carts found error' do
    let(:arguments) { ['app', 'create', 'app1', 'mock_standalone_cart', '--trace', '--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }

    context 'when run' do
      before(:each) do
        @rc = MockRestClient.new
        domain = @rc.add_domain("mockdomain")
      end
      it { expect { run }.should raise_error(RHC::MultipleCartridgesException) }
    end
  end

  describe 'app delete' do
    let(:arguments) { ['app', 'delete', '--trace', '-a', 'app1', '--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }

    context 'when run' do
      before(:each) do
        @rc = MockRestClient.new
        @domain = @rc.add_domain("mockdomain")
      end
      it "should not remove app when no is sent as input" do
        @app = @domain.add_application("app1", "mock_type")
        expect { run(["no"]) }.should exit_with_code(0)
        @domain.applications.length.should == 1
        @domain.applications[0] == @app
      end

      it "should remove app when yes is sent as input" do
        @app = @domain.add_application("app1", "mock_type")
        expect { run(["yes"]) }.should exit_with_code(0)
        @domain.applications.length.should == 0
      end
      it "should raise cartridge not found exception when no apps exist" do
        expect { run }.should raise_error RHC::ApplicationNotFoundException
      end
    end
  end


  describe 'app actions' do

    before(:each) do
      @rc = MockRestClient.new
      domain = @rc.add_domain("mockdomain")
      app = domain.add_application("app1", "mock_type")
      app.add_cartridge('mock_cart-1')
    end

    context 'app start' do
      let(:arguments) { ['app', 'start', '-a', 'app1','--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }
      it { run_output.should match('start') }
    end

    context 'app stop' do
      let(:arguments) { ['app', 'stop', 'app1','--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }

      it { run_output.should match('stop') }
    end

    context 'app force stop' do
      let(:arguments) { ['app', 'force-stop', 'app1','--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }

      it { run_output.should match('force') }
    end

    context 'app restart' do
      let(:arguments) { ['app', 'restart', 'app1','--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }
      it { run_output.should match('restart') }
    end

    context 'app reload' do
      let(:arguments) { ['app', 'reload', 'app1','--noprompt', '--config', 'test.conf', '-l', 'test@test.foo', '-p',  'password'] }
      it { run_output.should match('reload') }
    end
  end
end