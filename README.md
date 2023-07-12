<div align="center">

# asdf-jfrog [![Build](https://github.com/andavarv/asdf-jfrog/actions/workflows/build.yml/badge.svg)](https://github.com/andavarv/asdf-jfrog/actions/workflows/build.yml) [![Lint](https://github.com/andavarv/asdf-jfrog/actions/workflows/lint.yml/badge.svg)](https://github.com/andavarv/asdf-jfrog/actions/workflows/lint.yml)

[jfrog](https://github.com/andavarv/jfrog) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add jfrog
# or
asdf plugin add jfrog https://github.com/andavarv/asdf-jfrog.git
```

jfrog:

```shell
# Show all installable versions
asdf list-all jfrog

# Install specific version
asdf install jfrog latest

# Set a version globally (on your ~/.tool-versions file)
asdf global jfrog latest

# Now jfrog commands are available
jfrog --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/andavarv/asdf-jfrog/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Andavar Veeramalai](https://github.com/andavarv/)
