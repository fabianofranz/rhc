require 'rhc/commands/base'

module RHC::Commands
  class Deployment < Base

    summary "List deployments"
    syntax ""
    argument :app, "Application name (required)", ["-a", "--app name"], :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    option ["--date DATE"], "List deployments of a specific date"
    option ["--latest [INTEGER]", Integer], "List the latest deployment (or latest INTEGER deployments if provided)"
    alias_action :"deployments", :root_command => true
    def list(app)
      rest_app = rest_client.find_application(options.namespace, app)
      deployments = rest_app.deployments

      pager

      display_deployment_list(deployments)

      0
    end

    summary "Show details of the given deployment"
    syntax ""
    argument :id, "The deployment ID to show", ["--id ID"], :optional => false
    option ["-a", "--app NAME"], "Application name (required)", :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    def show(id)
      rest_app = rest_client.find_application(options.namespace, app)
      deployment = rest_app.deployments.select{|item| item.id == id}.first

      display_deployment(deployment)

      0
    end

    summary "Rollback deployment"
    syntax ""
    argument :id, "The deployment ID to roll-back the application", ["--id ID"], :optional => false
    option ["-a", "--app NAME"], "Application name (required)", :context => :app_context, :required => true
    option ["-n", "--namespace NAME"], "Namespace of your application", :context => :namespace_context, :required => true
    def rollback(id)
      say "Rolling back deployment #{id} ... "

      rest_app = rest_client.find_application(options.namespace, options.app)

      rest_app.rollback(id)

      success "done"

      0
    end

  end
end
