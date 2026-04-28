# forgejo-tf

## Dependencies
Dependencies can be found in the flake.nix file under the `devShells.default.buildInputs` section.

## Required ENV variables
```sh
export TF_VAR_FORGEJO_RUNNER_TOKEN=
export TF_VAR_ADMIN_USERNAME=
export TF_VAR_ADMIN_PASSWORD=
export TF_VAR_ADMIN_EMAIL=
```
`TF_VAR_FORGEJO_RUNNER_TOKEN` can be obtained once the `forgejo` deployment is live.
- For individual runner, go to Settings > Actions >  Runners. The token will be under "Create new runner"
- For global runner, go to Site administration > Actions > Runners. The token will be under "create new runner".


## Local Cluster
To deploy the local cluster, 
- `cd` into `local/cluster/` and run `tofu apply`.
- When the cluster is live. `cd` into `/local/cluster/resources` and run `tofu apply`. This will launch forgejo

To deploy runners,
- After assigning the runner token to `TF_VAR_FORGEJO_RUNNER_TOKEN`, `cd` into `local/forgejo` and run `tofu apply`.
