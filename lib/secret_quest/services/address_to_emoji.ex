defmodule SecretQuest.EmojiConverter do
  @moduledoc """
  A module to convert a binary string to a single emoji.
  """

  @emojis [
    "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇",
    "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚",
    "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔",
    "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "🤥",
    "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮",
    "🥵", "🥶", "🥴", "😵", "🤯", "🤠", "🥳", "😎", "🤓", "🧐",
    "😕", "😟", "🙁", "😮", "😯", "😲", "😳", "🥺", "😦", "😧",
    "😨", "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞", "😓",
    "😩", "😫", "😤", "😡", "😠", "🤬", "😈", "👿", "💀", "☠️",
    "💩", "🤡", "👹", "👺", "👻", "👽", "👾", "🤖", "😺", "😸",
    "😹", "😻", "😼", "😽", "🙀", "😿", "😾", "🙈", "🙉", "🙊"
  ]

  @doc """
  Converts a binary string to a single emoji.

  ## Examples

      iex> EmojiConverter.binary_to_emoji("hello")
      "😇"
  """
  def binary_to_emoji(binary) when is_binary(binary) do
    hash = :crypto.hash(:sha256, binary)
    index = :binary.decode_unsigned(hash) |> rem(length(@emojis))
    Enum.at(@emojis, index)
  end
end
