require 'rhc/commands/base'

module RHC::Commands
  class Env < Base
    summary "Manage your application's environment variables"
    syntax "<action>"
    description <<-DESC
      Manages the environment variables for a given application. To
      see a list of all environment variables use the command 
      'rhc env list <application>'. Note that some predefined 
      cartridge-level environment variables can also be overriden, 
      but most variables provided by gears are read-only.

      DESC
    default_action :help
    alias_action :"app env", :root_command => true

    summary "List all environment variables set on the application"
    description <<-DESC
      List all environment variables set on the application. Gear-
      level variables overriden by the 'rhc env set' command will
      also be listed.

      DESC
    syntax "<app> [-n namespace]"
    argument :app, "Application name (required)", ["-a", "--app name"], :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    def list(app)
      rest_app = rest_client.find_application(options.namespace, app)
      #env_vars = rest_app.environment_variables

      #pager

      #say table(env_vars.collect do |e|
      #  [e.id]
      #end)
      0
    end

    summary "Set one or more environment variable(s) to your application"
    description <<-DESC
      Set one or more environment variable(s) to your application. 
      Operands of the form 'VARIABLE=VALUE' set the environment 
      variable VARIABLE to value VALUE. VALUE may be empty, in that
      case 'VARIABLE='. Setting a variable to an empty value is
      different from unsetting it.

      Some default cartridge-level variables can be overriden, but
      variables provided by gears are read-only.

      DESC
    syntax "<app> <VARIABLE=VALUE> [... <VARIABLE=VALUE>] [-n namespace]"
    argument :app, "Application name (required)", ["-a", "--app name"], :context => :app_context, :required => true
    argument :env_var, "Environment variable name and value pair separated by an equal (=) sign, e.g. VARIABLE=VALUE", ["-e", "--env_var VARIABLE=VALUE"], :optional => false, :arg_type => :list
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    alias_action :add
    def set(app, env_var)
      rest_app = rest_client.find_application(options.namespace, app)
      env_var.each do |e|
        name, value = e.split '=', 2
        say "Setting variable #{name} to application '#{app}' ... "
      end

      #rest_cartridge = rest_app.set_environment_variable(name, value)

      success "Success"
      0
    end

    summary "Remove one or more environment variable(s) currently set to your application"
    description <<-DESC
      Remove one or more environment variable(s) currently set to your 
      application. Setting a variable to an empty value is
      different from unsetting it. When unsetting a default cartridge-
      level variable previously overriden, the variable will be set
      back to its default value.

      DESC
    syntax "<app> <VARIABLE> [... <VARIABLE>] [-n namespace]"
    argument :app, "Application name (required)", ["-a", "--app name"], :context => :app_context, :required => true
    argument :env_var, "Name of the environment variable(s), e.g. VARIABLE", ["-e", "--env_var VARIABLE"], :optional => false, :arg_type => :list
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    option ["--confirm"], "Pass to confirm removing the environment variable"
    alias_action :remove
    def unset(app, env_var)
      rest_app = rest_client.find_application(options.namespace, app)
      confirm_action "Removing a environment variable is a destructive operation that may result in loss of data.\n\nAre you sure you wish to remove environment variable(s) #{env_var.join(', ')} from application '#{rest_app.name}'?"

      env_var.each do |e|
        say "Removing environment variable #{e} from '#{rest_app.name}' ... "
        #rest_app.unset_environment_variable(e)
        success "removed"
      end

      0
    end

    summary "Show the value of one or more environment variable(s) currently set to your application"
    syntax "<app> <VARIABLE> [... <VARIABLE>] [-n namespace]"
    argument :app, "Application name (required)", ["-a", "--app name"], :context => :app_context, :required => true
    argument :env_var, "Name of the environment variable(s), e.g. VARIABLE", ["-e", "--env_var VARIABLE"], :optional => false, :arg_type => :list
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    def show(app, env_var)
      rest_app = rest_client.find_application(options.namespace, app)
      say "Checking value for variable(s) #{env_var.join(', ')} on application '#{app}' ... "

      success "Success"
      0
    end

  end
end
