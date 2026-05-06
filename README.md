# forgejo-tf

## Dependencies
Dependencies can be found in the flake.nix file under the `devShells.default.buildInputs` section.

## Required ENV variables
```sh
export TF_VAR_FORGEJO_RUNNER_TOKEN=
export TF_VAR_ADMIN_USERNAME=
export TF_VAR_ADMIN_PASSWORD=
export TF_VAR_ADMIN_EMAIL=


export TF_VAR_FORGEJO_BUCKET_ENDPOINT=
export TF_VAR_FORGEJO_BUCKET_ACCESS_ID=
export TF_VAR_FORGEJO_BUCKET_SECRET_ACCESS_KEY=f
export TF_VAR_FORGEJO_BUCKET_NAME=
export TF_VAR_FORGEJO_BUCKET_REGION=

export TF_VAR_DIGITALOCEAN_BACKEND_BUCKET_ENDPOINT=
export TF_VAR_BUCKET_NAME=
export TF_VAR_DIGITALOCEAN_BACKEND_BUCKET_NAME=
export TF_VAR_DIGITALOCEAN_REGION=nyc3
export TF_VAR_DIGITALOCEAN_SPACES_ACCESS_ID=
export TF_VAR_DIGITALOCEAN_SPACES_SECRET_KEY=

export TF_VAR_FORGEJO_BACKEND_BUCKET_ENDPOINT=
export TF_VAR_FORGEJO_BACKEND_BUCKET_NAME=

export TF_VAR_DIGITALOCEAN_TOKEN=
export TF_VAR_SSH_PRIVATE_KEY_PATH=
export TF_VAR_SSH_KEY_NAME=
export TF_VAR_VPC_NAME=

export TF_VAR_PORKBUN_API_KEY=
export TF_VAR_PORKBUN_API_SECRET=
export TF_VAR_ROOT_DOMAIN=
export TF_VAR_SUB_DOMAIN=
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
