import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom.{type Atom}
import gleam/result

pub type Config {
  Config(image: String, port: Int)
}

pub type StartInfo {
  StartInfo(container_id: String, port: Int)
}

type Container

pub fn start_container(config: Config) {
  let assert Ok(_) = start_link()

  let container = container_new(config.image)
  let container = with_exposed_port(container, config.port)
  let assert Ok(start_info) = do_start_container(container)

  let assert Ok(container_id) =
    start_info_item(start_info, "container_id", dynamic.string)
  let assert Ok([#(_, port)]) =
    start_info_item(
      start_info,
      "exposed_ports",
      dynamic.list(dynamic.tuple2(dynamic.int, dynamic.int)),
    )

  StartInfo(container_id, port)
}

@external(erlang, "Elixir.Testcontainers", "stop_container")
pub fn stop_container(container_id: String) -> Atom

@external(erlang, "Elixir.Testcontainers", "start_link")
fn start_link() -> Result(String, String)

@external(erlang, "Elixir.Testcontainers", "start_container")
fn do_start_container(
  container: Container,
) -> Result(Dict(Atom, Dynamic), String)

@external(erlang, "Elixir.Testcontainers.Container", "new")
fn container_new(image: String) -> Container

@external(erlang, "Elixir.Testcontainers.Container", "with_exposed_port")
fn with_exposed_port(container: Container, port: Int) -> Container

fn start_info_item(start_info, key, decoder) {
  start_info
  |> dict.get(atom.create_from_string(key))
  |> result.map_error(fn(_) { [] })
  |> result.try(decoder)
}
