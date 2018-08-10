# Reliability Engineering - Build Systems

This repository provides examples for provisioning a Jenkins build system. This build system is a containerised Jenkins (version 2) platform
on AWS, consisting of a master node and an agent node. Once provisioned, users log into the Jenkins using their Github account.

If you would like more information about the architecture of this build system, you can read the [architectural documentation].

## Examples

Follow [this example](https://github.com/alphagov/re-build-systems/tree/master/examples/gds_specific_dns_and_jenkins) if you are from GDS, or [this one](https://github.com/alphagov/re-build-systems/tree/master/examples/complete_deployment_of_dns_and_jenkins) otherwise.

### Debugging

To SSH into the master instance run:
```
ssh -i [path-to-the-private-ssh-key-you-generated] ubuntu@[my-env.my-team.build.gds-reliability.engineering]
```

To SSH into the agents instance you need to use the master node as a proxy, like so:
```
ssh -i [path-to-the-private-ssh-key-you-generated] -o ProxyCommand='ssh -W %h:%p ubuntu@[my-env.my-team.build.gds-reliability.engineering]' ubuntu@worker
```

Once logged in with the `ubuntu` user, you can switch to the root user by running `sudo su -`.

### Recommendations

Next, you may want to:

* enable AWS CloudTrail
* remove the generic SSH key used during provisioning and use personal keys
* remove the default `ubuntu` account from the AWS instance(s)

## Contributing

Refer to our [Contributing guide](CONTRIBUTING.md).

## Licence

[MIT License](LICENCE)

[architectural documentation]: docs/architecture/README.md
[Register a new OAuth application]: https://github.com/settings/applications/new
