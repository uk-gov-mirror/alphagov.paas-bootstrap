#!/usr/bin/env ruby

require "yaml"

CONCOURSE_ACCESS_ROLE = "concourse-access"

paas_trusted_people_path = ARGV[0]
enable_github = ENV["ENABLE_GITHUB"] == "true";
enable_google = ENV["ENABLE_GOOGLE"] == "true";
aws_account = ENV["AWS_ACCOUNT"]

if !File.exists? paas_trusted_people_path
  STDERR.puts "trusted people file at #{paas_trusted_people_path} cannot be found"
  exit 1
end

trusted_people = YAML.safe_load(File.read(paas_trusted_people_path), aliases: true)
users = trusted_people.fetch("users")

# Find users for this aws account with concourse access
concourse_users = users
  .select {|u|
    u["roles"][aws_account] != nil
  }
  .select { |u|
    u["roles"][aws_account].any? {|r|
      r["role"] == CONCOURSE_ACCESS_ROLE
    }
  }

config = {
  "instance_groups" =>  [
    {
      "name" => "concourse",
      "jobs" => [
        {
          "name" => "web",
          "properties" => {
            "main_team" => {
              "auth" => {}
            }
          }
        }
      ]
    }
  ]
}

if enable_github
  puts "Enabling GitHub access"
  some_without_github_username = concourse_users.any? {|u| u["github_username"] == nil}
  if some_without_github_username
    STDERR.puts %{
      Cannot enable GitHub access to Concourse.
      One or more users with the '#{CONCOURSE_ACCESS_ROLE}' role in '#{aws_account}' do not have 'github_username' set
    }

    exit 1
  end

  config["instance_groups"][0]["jobs"][0]["properties"]["github_auth"] = {
    "client_id" => "(( grab $GITHUB_CLIENT_ID ))",
    "client_secret" => "(( grab $GITHUB_CLIENT_SECRET ))"
  }

  config["instance_groups"][0]["jobs"][0]["properties"]["main_team"]["auth"]["github"] = {
    "users" => concourse_users.map{|u| u["github_username"]}
  }
end

if enable_google
  puts "Enabling Google access"
  some_without_google_id = concourse_users.any? {|u| u["email"] == nil}
  if some_without_google_id
    STDERR.puts %{
      Cannot enable Google access to Concourse.
      One or more users with the '#{CONCOURSE_ACCESS_ROLE}' role in '#{aws_account}' do not have 'email' set
    }

    exit 1
  end

  config["instance_groups"][0]["jobs"][0]["properties"]["generic_oidc"] = {
    "client_id" => "(( grab $GOOGLE_CLIENT_ID ))",
    "client_secret" => "(( grab $GOOGLE_CLIENT_SECRET ))",
    "issuer" => "https://accounts.google.com",
    "scopes" => ["openid", "profile", "email"],
    "user_name_key" => "email",
    "display_name" => "email",
    "hosted_domains" => ["digital.cabinet-office.gov.uk"]
  }

  config["instance_groups"][0]["jobs"][0]["properties"]["main_team"]["auth"]["oidc"] = {
    "users" => concourse_users.map{|u| u["email"]}
  }
end

puts config.to_yaml
