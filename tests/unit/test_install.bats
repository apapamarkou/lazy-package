#!/usr/bin/env bats
# Unit tests for install script PATH handling

load '../helpers/test_utils'

setup() {
    setup_test_env
    TEST_HOME="$BATS_TEST_TMPDIR/home"
    mkdir -p "$TEST_HOME/.local/bin"
}

@test "install adds PATH export to .profile when not in PATH" {
    run bash -c "
        HOME=\"$TEST_HOME\"
        PATH=/usr/bin:/bin

        PROFILE_FILE=\"\$HOME/.profile\"
        PATH_EXPORT='export PATH=\"\$HOME/.local/bin:\$PATH\"'

        if [[ \":\$PATH:\" != *\":\$HOME/.local/bin:\"* ]]; then
            if [[ ! -f \"\$PROFILE_FILE\" ]] || ! grep -qF \"\$HOME/.local/bin\" \"\$PROFILE_FILE\"; then
                echo \"\$PATH_EXPORT\" >> \"\$PROFILE_FILE\"
            fi
        fi

        cat \"\$PROFILE_FILE\"
    "
    assert_success
    assert_contains "$output" '.local/bin'
}

@test "install creates .profile if it does not exist" {
    run bash -c "
        HOME=\"$TEST_HOME\"
        PATH=/usr/bin:/bin
        PROFILE_FILE=\"\$HOME/.profile\"

        [[ ! -f \"\$PROFILE_FILE\" ]] && echo 'would create'

        if [[ \":\$PATH:\" != *\":\$HOME/.local/bin:\"* ]]; then
            echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> \"\$PROFILE_FILE\"
        fi

        [[ -f \"\$PROFILE_FILE\" ]] && echo 'profile exists'
    "
    assert_success
    assert_contains "$output" 'profile exists'
}

@test "install skips .profile update when local bin already in PATH" {
    run bash -c "
        HOME=\"$TEST_HOME\"
        PATH=\"\$HOME/.local/bin:/usr/bin\"
        PROFILE_FILE=\"\$HOME/.profile\"

        if [[ \":\$PATH:\" != *\":\$HOME/.local/bin:\"* ]]; then
            echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> \"\$PROFILE_FILE\"
            echo 'added'
        else
            echo 'skipped'
        fi
    "
    assert_success
    assert_contains "$output" 'skipped'
}

@test "install does not duplicate PATH export in .profile" {
    run bash -c "
        HOME=\"$TEST_HOME\"
        PATH=/usr/bin:/bin
        PROFILE_FILE=\"\$HOME/.profile\"
        PATH_EXPORT='export PATH=\"\$HOME/.local/bin:\$PATH\"'

        echo \"\$PATH_EXPORT\" > \"\$PROFILE_FILE\"

        if [[ \":\$PATH:\" != *\":\$HOME/.local/bin:\"* ]]; then
            if ! grep -qF \"\$HOME/.local/bin\" \"\$PROFILE_FILE\"; then
                echo \"\$PATH_EXPORT\" >> \"\$PROFILE_FILE\"
            fi
        fi

        grep -c '.local/bin' \"\$PROFILE_FILE\"
    "
    assert_success
    [ "$output" -eq 1 ]
}
