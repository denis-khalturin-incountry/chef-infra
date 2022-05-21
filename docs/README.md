## What is it?

This repository helps in preparing Chef Infra HA or Standalone version and adding users and organizations

## Dependencies

- [Chef Workstation](https://docs.chef.io/workstation)

### Preparing

Create an ssh key and deploy them to your hosts

```shell
# will be create file - cookbooks/ssh/attributes/default.rb
chef-solo -c solo.rb -o 'recipe[ssh::gen]'

# copying created ssh key to your hosts
awk -F "'" '/ip/{ORS=","; print $8}' cookbooks/chef-infra/attributes/default.rb | xargs -I {} chef-run --cookbook-repo-paths cookbooks --user ubuntu --sudo {} ssh::copy
```

### Deployment Standalone

```shell
awk -F "'" '/standalone.*ip/{ORS=","; print $6}' cookbooks/chef-infra/attributes/default.rb | xargs -I {} chef-run --cookbook-repo-paths cookbooks --user ubuntu --sudo {} chef-infra::standalone
```

### Deployment High Availability

First, deploy the backend servers

```shell
awk -F "'" '/backend.*ip/{ORS=","; print $8}' cookbooks/chef-infra/attributes/default.rb | xargs -I {} chef-run --cookbook-repo-paths cookbooks --user ubuntu --sudo {} chef-infra::ha-backend
```

Finally, deploy the frontend servers

```shell
awk -F "'" '/frontend.*ip/{ORS=","; print $8}' cookbooks/chef-infra/attributes/default.rb | xargs -I {} chef-run --cookbook-repo-paths cookbooks --user ubuntu --sudo {} chef-infra::ha-frontend
```

### Creating users and organizations

If you describe `default['server']['users']` and `default['server']['orgs']` applying `chef-infra::standalone` or `chef-infra::ha-frontend` will finished with creating users and organization.

Example of defining a list of users

```ruby
default['server']['users']['admin']['last_name'] = 'last_name'
default['server']['users']['admin']['first_name'] = 'first_name'
default['server']['users']['admin']['password'] = 'password'
default['server']['users']['admin']['email'] = 'mail@box.box'

default['server']['users']['foo']['last_name'] = 'last_name'
default['server']['users']['foo']['first_name'] = 'first_name'
default['server']['users']['foo']['password'] = 'password'
default['server']['users']['foo']['email'] = 'mail@box.foo'
```

Example of defining a list of organizations

```ruby
default['server']['orgs']['test']['association_user'] = 'admin'
default['server']['orgs']['foo']['association_user'] = 'foo'
```

### Load balancing

If you want to use an frontend group with more than one instance, then you need a properly configured load balancer.

Example of nginx configuration

```
upstream chef {
  ip_hash;

  server chef-frontend-01:443;
  server chef-frontend-02:443;
  server chef-frontend-03:443;
}

server {
    listen 443 ssl http2;
    server_name chef;

    access_log /var/log/nginx/chef.access.log main;
    error_log /var/log/nginx/chef.error.log error;

    location / {
        proxy_pass          https://chef;
    }
}
```
