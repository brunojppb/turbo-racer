defmodule Turbo do
  @moduledoc """
  Turbo keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @typedoc """
  Represents the result of a generic operation that can fail.
  - Success cases return an `:ok` tuple with the given type `t`.
  - Failure cases return an `:error` tuple with the error reason.
  """
  @type result(t) :: {:ok, t} | {:error, reason :: String.t()}

  @typedoc """
  Represents the result of a generic operation that can fail.
  - Success cases return an `:ok` tuple with the given type `success_t`.
  - Failure cases return an `:error` tuple with the given type `error_t`
  """
  @type result(success_t, failure_t) :: {:ok, success_t} | {:error, failure_t}

  @rand_size 32

  def generate_rand_token() do
    :crypto.strong_rand_bytes(@rand_size)
    |> Base.url_encode64(padding: false)
  end
end
