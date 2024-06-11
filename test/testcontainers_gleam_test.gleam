import gleam/dynamic
import gleam/erlang/atom
import gleeunit/should
import testcontainers_gleam.{Config}

pub fn main() {
  let start_info =
    testcontainers_gleam.start_container(Config(
      "redis:7.4-rc1-alpine3.20",
      6379,
    ))

  start_info.container_id
  |> dynamic.from
  |> dynamic.classify
  |> should.equal("String")

  start_info.port
  |> dynamic.from
  |> dynamic.classify
  |> should.equal("Int")

  let stop_info = testcontainers_gleam.stop_container(start_info.container_id)
  stop_info |> should.equal(atom.create_from_string("ok"))
}
