defmodule PestServer.UserDetails do
  defstruct id: 0,
            name: "John Doe"

  @type t :: %PestServer.UserDetails{
    id: integer,
    name: String.t}
end