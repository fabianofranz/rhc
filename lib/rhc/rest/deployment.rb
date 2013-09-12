module RHC
  module Rest
    class Deployment < Base
      define_attr :description, :ref, :artifact_url

      def <=>(other)
        description <=> other.description
      end
    end
  end
end
