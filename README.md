# testcontainers_gleam

[![Package Version](https://img.shields.io/hexpm/v/testcontainers_gleam)](https://hex.pm/packages/testcontainers_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/testcontainers_gleam/)

```sh
gleam add --dev testcontainers_gleam
```
```gleam
import testcontainers_gleam.{Config}

pub fn main() {
  let start_info =
    testcontainers_gleam.start_container(Config(
      "redis:7.4-rc1-alpine3.20",
      6379,
    ))

  // start_info.port contains host port

  testcontainers_gleam.stop_container(start_info.container_id)
}
```

Further documentation can be found at <https://hexdocs.pm/testcontainers_gleam>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
