import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
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
  let assert Ok(start_info): Result(Dict(Atom, Dynamic), String) =
    do_start_container(container)

  let assert Ok(container_id) =
    start_info_item(start_info, "container_id", fn(dynamic_container_id) {
      decode.run(dynamic_container_id, decode.string)
    })

  let assert Ok(port) = get_port(start_info)
  StartInfo(container_id, port)
}

fn get_port(start_info: Dict(Atom, Dynamic)) -> Result(Int, Nil) {
  let assert Ok([port_pair]) =
    start_info_item(start_info, "exposed_ports", fn(dynamic_exposed_ports) {
      decode.run(dynamic_exposed_ports, decode.list(decode.list(decode.int)))
    })

  case port_pair {
    [_, p] -> Ok(p)
    _ -> Error(Nil)
  }
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

fn start_info_item(
  start_info: Dict(Atom, a),
  key: String,
  decoder: fn(a) -> Result(b, List(c)),
) -> Result(b, List(c)) {
  start_info
  |> dict.get(atom.create(key))
  |> result.map_error(fn(_) { [] })
  |> result.try(decoder)
}
