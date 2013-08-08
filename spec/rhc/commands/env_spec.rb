require 'spec_helper'
require 'rest_spec_helper'
require 'rhc/commands/env'
require 'rhc/config'

describe RHC::Commands::Env do

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
          { :domain_id       => 'mock_domain_1',
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
          { :domain_id       => 'mock_domain_1',
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

end
