require 'rhc/commands/base'

module RHC::Commands
  class Env < Base
    summary "Manage your application environment variables"
    syntax "<action>"
    description <<-DESC
      Manages the environment variables for the given application. To
      see a list of all environment variables use the command 
      rhc env list <appname>. Note that some predefined system
      environment variables can be overriden. If you unset an 
      overriden system env var the default system value will be set. 
      DESC
    default_action :help
    alias_action :"app env", :root_command => true

    summary "List environment variables set on the application"
    syntax "<app>"
    argument :app, "Application name (required)", ["-a", "--app name"], :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    def list
      list = rest_client.find_application(options.namespace, options.app, :include => :cartridges)
      env_vars = rest_app.environment_variables

      pager

      say table(env_vars.collect do |e|
        [e.id]
      end)
      0
    end

    summary "Set an environment variable to your application"
    syntax "<app> [-e] NAME=VALUE [--namespace NAME]"
    option ["-n", "--namespace NAME"], "Namespace of the application you are setting the environment variable to", :context => :namespace_context, :required => true
    option ["-a", "--app NAME"], "Application you are setting the environment variable to", :context => :app_context, :required => true
    argument :env_var,  "Pair of environment variable name and value, e.g. VAR_NAME=VAR_VALUE", ["-e", "--env_var env_var"]
    def set(env_var)
      name, value = env_var.split '=', 2
      say "Setting variable #{name} to application '#{options.app}' ... "

      rest_app = rest_client.find_application(options.namespace, options.app, :include => :cartridges)
      rest_cartridge = rest_app.set_environment_variable(name, value)

      success "Success"
      0
    end

    summary "Remove a environment variable from your application"
    syntax "<env_var_name> [--namespace NAME] [--app NAME]"
    argument :env_var_name,  "The name of the environment variable", ["-e", "--env_var_name env_var_name"]
    option ["-n", "--namespace NAME"], "Namespace of the application you are removing the cartridge from", :context => :namespace_context, :required => true
    option ["-a", "--app NAME"], "Application you are removing the cartridge from", :context => :app_context, :required => true
    option ["--confirm"], "Pass to confirm removing the environment variable"
    def unset(env_var_name)
      rest_app = rest_client.find_application(options.namespace, options.app, :include => :cartridges)
      confirm_action "Removing a environment variable is a destructive operation that may result in loss of data.\n\nAre you sure you wish to remove environment variable #{env_var_name} from '#{rest_app.name}'?"

      say "Removing environment variable #{env_var_name} from '#{rest_app.name}' ... "
      rest_app.unset_environment_variable(env_var_name)
      success "removed"

      0
    end

    summary "Show the value of an environment variable set to your application"
    syntax "<app> [-e] NAME [--namespace NAME]"
    option ["-n", "--namespace NAME"], "Namespace of the application you are setting the environment variable to", :context => :namespace_context, :required => true
    option ["-a", "--app NAME"], "Application you are setting the environment variable to", :context => :app_context, :required => true
    argument :env_var_name,  "Pair of environment variable name and value, e.g. VAR_NAME=VAR_VALUE", ["-e", "--env_var_name env_var_name"]
    def show(env_var_name)
      say "Checking value for variable #{env_var_name} on application '#{options.app}' ... "

      success "Success"
      0
    end

  end
end
