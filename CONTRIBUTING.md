# How to contribute

## Static analysis

We using [ShellCheck](https://github.com/koalaman/shellcheck) to static analyse for our shell scripts. Please run it in your machine before commit or before send pull requests.

If you have any reason to keep ShellCheck warnings, you may ignore it as follows. See [Ignore](https://github.com/koalaman/shellcheck/wiki/Ignore) for more information.

```
# shellcheck disable=SC2116,SC2086
hash=$(echo ${hash})    # trim spaces
```

But, please avoid ignoring all instances in a file without unit test and SC2039 (to use local variable).

## Unit test

We using [shUnit2](https://github.com/kward/shunit2) to writing unit test for shell scripts. We'll be happy if you send pull requests with unit test of your code.

Also, we using [kcov](https://github.com/SimonKagstrom/kcov) to take code coverage. In general, unit test coverage should be 100%. We are aiming for 100% code coverage, and We think that's a good thing to high quality.

## Coding conventions

Our coding style is here.

- Use bourne shell
- 4 space indent
- Global variable should be large characters
- Local variable should be small characters with `local` command
- Function name should be start with `_`. for example, `_function_name(){}`
- In `basepkg`, specify and check commands that are not defined in POSIX for portability
- Keep small function for readability
