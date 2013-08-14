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
    syntax "<VARIABLE=VALUE> [... <VARIABLE=VALUE>] [--namespace NAME] [--app NAME]"
    argument :env, "Environment variable name and value pair separated by an equal (=) sign, e.g. VARIABLE=VALUE", ["-e", "--env VARIABLE=VALUE"], :optional => false, :arg_type => :list
    option ["-a", "--app NAME"], "Application name (required)", :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    option ["--confirm"], "Pass to confirm setting the environment variable(s)"
    alias_action :add
    def set(env)
      rest_app = rest_client.find_application(options.namespace, options.app, :include => :environment_variables
        )

      env_vars = {}
      env.each {|e| env_vars.merge! collect_env_vars(e) }

      say "Setting environment variable(s) to application '#{rest_app.name}':"

      env_vars.each {|key, value| default_display_env_var(key, value) }

      confirm_action 'Confirm?'

      say 'Wait ... '
      rest_app.set_environment_variables(env_vars)
      success 'Success'

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
    syntax "<VARIABLE> [... <VARIABLE>] [--namespace NAME] [--app NAME]"
    argument :env, "Name of the environment variable(s), e.g. VARIABLE", ["-e", "--env VARIABLE"], :optional => false, :arg_type => :list
    option ["-a", "--app NAME"], "Application name (required)", :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    option ["--confirm"], "Pass to confirm removing the environment variable"
    alias_action :remove
    def unset(env)
      rest_app = rest_client.find_application(options.namespace, options.app, :include => :environment_variables)

      env_vars = []

      say 'Removing environment variables is a destructive operation that may result in loss of data.'

      env.each do |e|
        default_display_env_var(e)
        env_vars << e
      end

      confirm_action "Are you sure you wish to remove the environment variable(s) above from application '#{rest_app.name}'?"
      say 'Wait ... '
      rest_app.unset_environment_variables(env_vars)
      success 'Success'

      0
    end

    summary "List all environment variables set on the application"
    description <<-DESC
      List all environment variables set on the application.
      Gear-level variables overriden by the 'rhc env set' command
      will also be listed.

      DESC
    syntax "<app> [--namespace NAME]"
    argument :app, "Application name (required)", ["-a", "--app name"], :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    option ["--table"], "Format output as table"
    option ["--quotes"], "Format output with double quotes for values"
    def list(app)
      rest_app = rest_client.find_application(options.namespace, app, :include => :environment_variables)
      rest_env_vars = rest_app.environment_variables

      pager

      display_env_var_list(rest_env_vars, options.table ? :table : options.quotes ? :quotes : :env)

      0
    end

    summary "Show the value of one or more environment variable(s) currently set to your application"
    syntax "<VARIABLE> [... <VARIABLE>] [--namespace NAME] [--app NAME]"
    argument :env, "Name of the environment variable(s), e.g. VARIABLE", ["-e", "--env VARIABLE"], :optional => false, :arg_type => :list
    option ["-a", "--app NAME"], "Application name (required)", :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    option ["--table"], "Format output as table"
    option ["--quotes"], "Format output with double quotes for values"
    def show(env)
      rest_app = rest_client.find_application(options.namespace, options.app, :include => :environment_variables)
      rest_env_vars = rest_app.find_environment_variables(env)

      pager

      display_env_var_list(rest_env_vars, options.table ? :table : options.quotes ? :quotes : :env)

      0
    end

  end

end
