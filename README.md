## asdf-smithy

Install the [Smithy](https://smithy.io) CLI using [asdf](https://asdf-vm.com).

*asdf* is a tool that makes it easy to install mutliple versions of a tool
on Linux or macOS. *asdf-smithy* is an asdf plugin that allows you to install
different versions of the Smithy CLI using asdf.


## Installation

First, install asdf by following their
[getting started guide](https://asdf-vm.com/guide/getting-started.html)

Next, setup Smithy with asdf using:

```
asdf plugin add smithy https://github.com/smithy-lang/asdf-smithy.git
```

Finally, you can use the latest version of the Smithy CLI using:

```
asdf install smithy latest
```

## Testing:

```shell
# asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]
asdf plugin test smithy https://github.com/smithy-lang/asdf-smithy.git "smithy --help"
```
Tests are automatically run in GitHub Actions on push and PR.

Additional asdf usage information can be found in
[the asdf documentation](https://asdf-vm.com/guide/getting-started.html#_4-install-a-plugin).


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the Apache-2.0 License.

