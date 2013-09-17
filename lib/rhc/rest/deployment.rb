module RHC
  module Rest
    class Deployment < Base
      define_attr :id, :ref, :artifact_url, :hot_deploy, :state

      def <=>(other)
        description <=> other.description
      end
    end
  end
end
