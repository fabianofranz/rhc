require 'rhc/commands/base'

module RHC::Commands
  class Deployment < Base

    summary "Deploy"
    syntax ""
    argument :ref, "Git tag, branch or commit id or binary file to be deployed", ["--ref REF"], :optional => false
    argument :description, "Git ref or binary file to be deployed", ["--description DESCRIPTION"], :optional => true
    option ["-a", "--app NAME"], "Application name (required)", :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    option ["-e", "--env VARIABLE=VALUE"], "Environment variable(s) to be set for this deploy, or path to a file containing environment variables", :option_type => :list
    option ["--[no-]restart"], "Restart after deploying?"
    option ["--[no-]start"], "Start after deploying?"
    option ["--after COMMAND"], "After deploy execute this command on all gears deployed. Requires a command."
    option ["--repo PATH"], "Path to git repo (auto-detect if in repo)"
    alias_action :"deploy", :root_command => true
    def create(ref, description)
      say "Deploying #{ref} ... "

      rest_app = rest_client.find_application(options.namespace, options.app)

      rest_app.deploy(ref, description)

      success "done"
    end

    summary "List deployments"
    syntax ""
    argument :app, "Application name (required)", ["-a", "--app name"], :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    alias_action :"deployments", :root_command => true
    def list(app)
      rest_app = rest_client.find_application(options.namespace, app)
      deployments = rest_app.deployments

      pager

      display_deployment_list(deployments)
    end

    def show
    end

    summary "Rollback deployment"
    syntax ""
    argument :id, "The deployment ID to roll-back the application", ["--id ID"], :optional => false
    option ["-a", "--app NAME"], "Application name (required)", :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    def rollback(id)
      say "Rolling back deployment #{id} ... "

      rest_app = rest_client.find_application(options.namespace, options.app)

      rest_app.rollback

      success "done"
    end

    def config
    end

  end
end
