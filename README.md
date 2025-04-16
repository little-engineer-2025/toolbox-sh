# toolbox

Helpers for getting started a toolbox ready to work
with different code languages, and allow it to provision
in a repeatable way.

## Getting started

> It is recommended to use [direnv](https://github.com/direnv/direnv)
> to manage local environment variables for your repository.
> When using it, define:
>
>     export TOOLBOX="your-toolbox-name"
>     export TOOLBOX_PROFILE="pre-defined-profile"
>
> If you are not using **direnv**, then be ensure that the
> environment variables above are defined with the right
> values to avoid unwanted behaviors.

- Install wrapper on your local home directory by:

    ```sh
    ./toolbox.sh install
    ```

  > Now you can run toolbox.sh wrapper from any place.

- List pre-defined profiles by:

    ```sh
    ./toolbox.sh profiles
    ```

- Initialize a toolbox for your repository.

    ```sh
    toolbox.sh create
    ```

- Enter into the toolbox by:

    ```sh
    toolbox.sh enter
    ```

- Re-run the toolbox preparation process by:

    ```sh
    toolbox.sh prepare
    ```

- When you finish, you can release the toolbox created by:

    ```sh
    toolbox.sh rm
    ```

- To start creating a custom toolbox provisioning, run:

    ```sh
    toolbox.sh localcfg
    ```

  > Now edit the fresh created `toolbox.sh` in your current
  > directory, and add the customizations.
  >
  > You do not need to define TOOLBOX_PROFILE environment
  > variable when you are using your custom `toolbox.sh`
  > profile provisioner.

## Architecture

- `./toolbox.sh`: Is the entry-point and main content.
- `./toolbox.{TOOLBOX_PROFILE}.sh` is a pre-defined profile, to
  make life easier when starting to use them.
- `./toolbox.common.sh` is included by all the profiles
  (pre-defined, or customized).
- `./toolbox_helper.sh` is a set of functions to help you
  on defining your custom profiles; they are used on the
  pre-defined profiles.

## Features

- Allow pre-defined profiles:
  - python
  - golang
  - rust
  - c
  - c++
- Allow custom profiles on current directory.
- Allow relaunch prepare statement.

## Creating a new profile

Just create a `toolbox.my-new-profile.sh` file and get
starting by:

```sh
pkgs+=() # TODO Add your rpm packages here
include "toolbox.common.sh"

# TODO Add here the actions to prepare the environmnet
#      for your profile
```

## Contributing

Read the [CONTRIBUTING](CONTRIBUTING.md) guidelines.
