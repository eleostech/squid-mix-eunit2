# MixEunit

Allows you to run eunit tests with "mix eunit".

## Installation

```
mix archive.build
mix archive.install
```

This installs to `~/.mix/archives`.

If you're using `kiex` to manage a different project, and you want `mix eunit` to
be available there, either run `mix archive.install path/to/mix_eunit` from that
project, or set MIX_ARCHIVES when building this project.

For example:

```
mix archive.build \
    && mix archive.install --force \
    && MIX_ARCHIVES=$HOME/.kiex/mix/archives/elixir-1.9.4 mix archive.install --force
```
