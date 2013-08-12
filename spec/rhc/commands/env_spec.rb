require 'spec_helper'
require 'rest_spec_helper'
require 'rhc/commands/env'
require 'rhc/config'

describe RHC::Commands::Env do

  def exit_with_code_and_message(code, message=nil)
    expect{ run }.to exit_with_code(code)
    run_output.should match(message) if message
  end

  def succeed_with_message(message="done")
    exit_with_code_and_message(0, message)
  end

  let(:client_links)   { mock_response_links(mock_client_links) }
  let(:domain_0_links) { mock_response_links(mock_domain_links('mock_domain_0')) }
  let(:app_0_links)    { mock_response_links(mock_app_links('mock_domain_0', 'mock_app_0')) }
  let!(:rest_client){ MockRestClient.new }

  before(:each) do

    user_config
    domain = rest_client.add_domain("mock_domain_0")
    domain.add_application("mock_app_0", "ruby-1.8.7")

    stub_api_request(:any, app_0_links['SET_ENVIRONMENT_VARIABLES']['relative'], false).
      with(:body => {:event => 'set-environment-variables', :environment_variables => {'FOO' => '123', 'BAR' => '456'}}).
      to_return({ :body   => {
          :type => 'application',
          :data =>
          { :domain_id       => 'mock_domain_0',
             :name            => 'mock_app_0',
             :creation_time   => Time.new.to_s,
             :uuid            => 1234,
             :aliases         => [],
             :server_identity => 'mock_server_identity',
             :environment_variables => {'FOO' => '123', 'BAR' => '456'},
             :links           => mock_response_links(mock_app_links('mock_domain_0','mock_app_0')),
           },
          :messages => [{:text => "RESULT:\nApplication event 'set-environment-variables' successful"}]
        }.to_json,
        :status => 200
      })

    stub_api_request(:any, app_0_links['UNSET_ENVIRONMENT_VARIABLES']['relative'], false).
      with(:body => {:event => 'unset-environment-variables', :environment_variables => ['FOO', 'BAR']}).
      to_return({ :body   => {
          :type => 'application',
          :data =>
          { :domain_id       => 'mock_domain_0',
             :name            => 'mock_app_0',
             :creation_time   => Time.new.to_s,
             :uuid            => 1234,
             :aliases         => [],
             :server_identity => 'mock_server_identity',
             :environment_variables => {},
             :links           => mock_response_links(mock_app_links('mock_domain_0','mock_app_0')),
           },
          :messages => [{:text => "RESULT:\nApplication event 'unset-environment-variables' successful"}]
        }.to_json,
        :status => 200
      })

  end

  describe 'env help' do
    let(:arguments) { ['env', '--help'] }
    context 'help is run' do
      it "should display help" do
        expect { run }.to exit_with_code(0)
      end
      it('should output usage') { run_output.should match("Usage: rhc env <action>$") }
    end
  end

  describe 'env set --help' do
    [['env', 'set', '--help'],
     ['env', 'add', '--help'],
     ['set-env', '--help'],
     ['env-set', '--help']
    ].each_with_index do |args, i|
      context "help is run run with arguments #{i}" do
        let(:arguments) { args }
        it "should display help" do
          expect { run }.to exit_with_code(0)
        end
        it('should output usage') { run_output.should match("Usage: rhc env-set <VARIABLE=VALUE>") }
      end
    end
  end

  describe 'env unset --help' do
    [['env', 'unset', '--help'],
     ['env', 'remove', '--help'],
     ['unset-env', '--help'],
     ['env-unset', '--help']
    ].each_with_index do |args, i|
      context "help is run run with arguments #{i}" do
        let(:arguments) { args }
        it "should display help" do
          expect { run }.to exit_with_code(0)
        end
        it('should output usage') { run_output.should match("Usage: rhc env-unset <VARIABLE>") }
      end
    end
  end

  describe 'env list --help' do
    [['env', 'list', '--help'],
     ['list-env', '--help'],
     ['env-list', '--help']
    ].each_with_index do |args, i|
      context "help is run run with arguments #{i}" do
        let(:arguments) { args }
        it "should display help" do
          expect { run }.to exit_with_code(0)
        end
        it('should output usage') { run_output.should match("Usage: rhc env-list <app> [--namespace NAME]") }
      end
    end
  end

  describe 'env show --help' do
    [['env', 'show', '--help'],
     ['show-env', '--help'],
     ['env-show', '--help']
    ].each_with_index do |args, i|
      context "help is run run with arguments #{i}" do
        let(:arguments) { args }
        it "should display help" do
          expect { run }.to exit_with_code(0)
        end
        it('should output usage') { run_output.should match("Usage: rhc env-show <VARIABLE>") }
      end
    end
  end

  describe 'set env' do

    [['env', 'set', 'TEST_ENV_VAR=1', '--app', 'mock_app_0', '--noprompt', '--confirm'],
     ['set-env', 'TEST_ENV_VAR=1', '--app', 'mock_app_0', '--noprompt', '--confirm'],
     ['env', 'set', '-e', 'TEST_ENV_VAR=1', '--app', 'mock_app_0', '--noprompt', '--confirm' ],
     ['env', 'set', '--env', 'TEST_ENV_VAR=1', '--app', 'mock_app_0', '--noprompt', '--confirm' ],
     #['env', 'set', '--env', 'TEST_ENV_VAR="1"', '--app', 'mock_app_0', '--noprompt', '--confirm' ],
     #['env', 'set', '--env', "TEST_ENV_VAR='1'", '--app', 'mock_app_0', '--noprompt', '--confirm' ]
    ].each_with_index do |args, i|
      context "when run with single env var #{i}" do
        let(:arguments) { args }
        it { succeed_with_message /Setting environment variable\(s\) to application 'mock_app_0'/ }
        it { succeed_with_message /TEST_ENV_VAR=1/ }
        it { succeed_with_message /Wait \.\.\./ }
        it { succeed_with_message /Success/ }
      end
    end

    [['env', 'set', 'TEST_ENV_VAR1=1', 'TEST_ENV_VAR2=2', 'TEST_ENV_VAR3=3', '--app', 'mock_app_0', '--noprompt', '--confirm' ],
     ['set-env', 'TEST_ENV_VAR1=1', 'TEST_ENV_VAR2=2', 'TEST_ENV_VAR3=3', '--app', 'mock_app_0', '--noprompt', '--confirm' ]
     #['set-env', '-e', 'TEST_ENV_VAR1=1', '-e', 'TEST_ENV_VAR2=2', '-e', 'TEST_ENV_VAR3=3', '--app', 'mock_app_0', '--noprompt', '--confirm' ]
     #['set-env', '--env', 'TEST_ENV_VAR1=1', '--env', 'TEST_ENV_VAR2=2', '--env', 'TEST_ENV_VAR3=3', '--app', 'mock_app_0', '--noprompt', '--confirm' ]
    ].each_with_index do |args, i|
      context "when run with multiple env vars #{i}" do
        let(:arguments) { args }
        it { succeed_with_message /Setting environment variable\(s\) to application 'mock_app_0'/ }
        it { succeed_with_message /TEST_ENV_VAR1=1/ }
        it { succeed_with_message /TEST_ENV_VAR2=2/ }
        it { succeed_with_message /TEST_ENV_VAR3=3/ }
        it { succeed_with_message /Wait \.\.\./ }
        it { succeed_with_message /Success/ }
      end
    end

    context 'when run with multiple env vars from file' do
      #TODO
    end

    context 'when run with --noprompt and without --confirm' do
      let(:arguments) { ['env', 'set', 'TEST_ENV_VAR=1', '--app', 'mock_app_0', '--noprompt' ] }
      it "should ask for confirmation" do
        expect{ run }.to exit_with_code(1)
      end
      it("should output confirmation") { run_output.should match("This action requires the --confirm option") }
    end
  end

  describe 'unset env' do
    
    [['env', 'unset', 'TEST_ENV_VAR', '--app', 'mock_app_0', '--noprompt', '--confirm'],
     ['unset-env', 'TEST_ENV_VAR', '--app', 'mock_app_0', '--noprompt', '--confirm'],
     ['env', 'unset', '-e', 'TEST_ENV_VAR', '--app', 'mock_app_0', '--noprompt', '--confirm' ],
     ['env', 'unset', '--env', 'TEST_ENV_VAR', '--app', 'mock_app_0', '--noprompt', '--confirm' ]
    ].each_with_index do |args, i|
      context "when run with single env var #{i}" do
        let(:arguments) { args }
        it { succeed_with_message /TEST_ENV_VAR/ }
        it { succeed_with_message /Wait \.\.\./ }
        it { succeed_with_message /Success/ }
      end
    end

    [['env', 'unset', 'TEST_ENV_VAR1', 'TEST_ENV_VAR2', 'TEST_ENV_VAR3', '--app', 'mock_app_0', '--noprompt', '--confirm' ],
     ['unset-env', 'TEST_ENV_VAR1', 'TEST_ENV_VAR2', 'TEST_ENV_VAR3', '--app', 'mock_app_0', '--noprompt', '--confirm' ]
    ].each_with_index do |args, i|
      context "when run with multiple env vars #{i}" do
        let(:arguments) { args }
        it { succeed_with_message /TEST_ENV_VAR1/ }
        it { succeed_with_message /TEST_ENV_VAR2/ }
        it { succeed_with_message /TEST_ENV_VAR3/ }
        it { succeed_with_message /Wait \.\.\./ }
        it { succeed_with_message /Success/ }
      end
    end

    context 'when run with --noprompt and without --confirm' do
      let(:arguments) { ['env', 'unset', 'TEST_ENV_VAR', '--app', 'mock_app_0', '--noprompt' ] }
      it "should ask for confirmation" do
        expect{ run }.to exit_with_code(1)
      end
      it("should output confirmation") { run_output.should match("This action requires the --confirm option") }
    end
  end

  describe 'list env' do
    context 'when list with default format' do
      let(:arguments) { ['env', 'list', '--app', 'mock_app_0'] }
      #it { succeed_with_message /FOO=123/ }
      #it { succeed_with_message /BAR=456/ }
      it "should exit okay" do
        expect{ run }.to exit_with_code(0)
      end
    end

    context 'when list with export format' do
      let(:arguments) { ['env', 'list', '--app', 'mock_app_0', '--export'] }
      #it { succeed_with_message /FOO="123"/ }
      #it { succeed_with_message /BAR="456"/ }
      it "should exit okay" do
        expect{ run }.to exit_with_code(0)
      end
    end

    context 'when list with table format' do
      let(:arguments) { ['env', 'list', '--app', 'mock_app_0', '--table'] }
      it "should exit okay" do
        expect{ run }.to exit_with_code(0)
      end
    end
  end

  describe 'show env' do
    context 'when show with default format' do
      let(:arguments) { ['env', 'show', 'FOO', '--app', 'mock_app_0'] }
      it "should raise env var not found exception" do
        expect { run }.to raise_error RHC::EnvironmentVariableNotFoundException
      end
      #it { succeed_with_message /FOO=123/ }
    end

    context 'when show with export format' do
      let(:arguments) { ['env', 'show', 'FOO', '--app', 'mock_app_0', '--export'] }
      it "should raise env var not found exception" do
        expect { run }.to raise_error RHC::EnvironmentVariableNotFoundException
      end
      #it { succeed_with_message /FOO="123"/ }
    end

    context 'when show with table format' do
      let(:arguments) { ['env', 'show', 'FOO', '--app', 'mock_app_0', '--table'] }
      it "should raise env var not found exception" do
        expect { run }.to raise_error RHC::EnvironmentVariableNotFoundException
      end
      #it "should exit okay" do
      #  expect{ run }.to exit_with_code(0)
      #end
    end

    context 'when show with not set env var' do
      let(:arguments) { ['env', 'show', 'FOO', '--app', 'mock_app_0'] }
      it "should raise env var not found exception" do
        expect { run }.to raise_error RHC::EnvironmentVariableNotFoundException
      end
      #it { succeed_with_message /FOO=123/ }
    end
  end

  describe 'create app with env vars' do
  end

  describe 'add cartridge with env vars' do
  end

end
