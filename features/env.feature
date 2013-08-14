@application @domain_required
Feature: Environment Variables Operations

  @init
  Scenario: Set One Environment Variable
    Given a php application is created
    When a new environment variable "FOO" is set with value "BAR"
    Then the output includes the environment variable information "FOO=BAR"
    And the command exits with status code 0

