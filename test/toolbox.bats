#!/usr/bin/bats

setup() {
  load ../toolbox.sh
}

@test "is_the_default_script" {
    TOOLBOX_PROFILE_PATH="/tmp" PWD="/tmp" is_the_default_script
    ! TOOLBOX_PROFILE_PATH="/tmp2" PWD="/tmp" is_the_default_script
}

@test "check_toolbox_is_not_empty" {
    TOOLBOX="some-toolbox-name" check_toolbox_is_not_empty
    export TOOLBOX="" run check_toolbox_is_not_empty
    # TODO Add additional asserts
}

@test "check_toolbox_profile_is_not_empty" {
    TOOLBOX_PROFILE="/tmp" check_toolbox_profile_is_not_empty
    export TOOLBOX_PROFILE="" run check_toolbox_profile_is_not_empty
    # TODO Add additional asserts
}
 
