include RHCHelper

When /^'rhc env (\S+)( .*?)?'(?: command)? is run$/ do |subcommand, rest|
  if subcommand =~ /^(set|unset|list|show)$/
    Env.send subcommand.to_sym, rest
    @env_output = Env.env_output
    @exitcode = Env.exitcode
  end
end

When /^a new environment variable "(.*?)" is set with value "(.*)"$/ do |name, value|
  step "'rhc env set #{name}=#{value}' is run"
end

