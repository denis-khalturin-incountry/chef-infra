node.override[:package] = node[:packages][:frontend]

include_recipe 'chef-infra::package'
include_recipe 'chef-infra::reconfigure'
