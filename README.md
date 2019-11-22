# MixEunit

Allows you to run eunit tests with "mix eunit":

```
mix eunit
```

Supports umbrella projects.

## Installation

```
mix archive.build
mix archive.install
```

This installs to `~/.mix/archives`.

If you're using `kiex` to manage a different project, and you want `mix eunit` to
be available there, there are two options:

1. Set MIX_ARCHIVES when building this project.
2. Run `mix archive.build` in this project, to create the `.ez` file and then run `mix archive.install path/to/mix_eunit/mix_eunit-0.1.0.ez` from the other project.

For example:

```
mix archive.build \
    && mix archive.install --force \
    && MIX_ARCHIVES=$HOME/.kiex/mix/archives/elixir-1.9.4 mix archive.install --force
```

## Usage

```
MIX_ENV=test mix do compile, eunit
```
