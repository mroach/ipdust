defmodule Ipdust.RDAPNetworkId do
  @moduledoc """
  Searches through RDAP responses to try to find a friendly network ID such as ISP
  or company name
  """

  alias RDAP.{Entity, Response, VCard}

  def identify(ip) when is_binary(ip), do: ip |> RDAP.lookup_ip |> identify
  def identify({:ok, %Response{} = response}), do: identify(response)
  def identify(%Response{} = response) do
    finders = [
      fn r -> r |> entity_with_role("registrant") |> entity_descriptor end,
      &remark_description(&1),
      &network_name(&1),
      fn r -> r |> entity_with_role("abuse") |> entity_descriptor end
    ]

    Enum.find_value(finders, fn finder -> finder.(response) end)
  end
  def identify(_), do: nil

  def network_name(%Response{raw_response: %{name: name}}), do: name
  def network_name(_), do: nil

  def entity_descriptor(%Entity{vcard: %VCard{formatted_name: name}}), do: name
  def entity_descriptor(%Entity{vcard: %VCard{address: addr}}) do
    VCard.Address.addressee(addr)
  end
  def entity_descriptor(_), do: nil

  @doc """
  (This is a bit of a mess and could probably use a refactor)
  Searches for the first registrant in the entities of an RDAP response.

  There seem to be many ways of structuring the entities in an RDAP response based
  on the ownership structure of the network, the NIC, or who knows.

  Sometimes the registrant is the only object. Sometimes it's nested under "abuse"
  or "technical". Why? No idea. So this recursively searches the entities and finds
  the first one with the registrant role
  """
  def entity_with_role(%Response{entities: entities}, role) when is_binary(role) do
    entity_with_role(entities, role)
  end
  def entity_with_role(entities, role) when is_list(entities) and is_binary(role) do
    Enum.find_value(entities, &entity_with_role(&1, role))
  end
  def entity_with_role(%Entity{roles: roles, entities: subentities} = entity, role) when is_binary(role) do
    if Enum.member?(roles, role) do
      entity
    else
      entity_with_role(subentities, role)
    end
  end
  def entity_with_role(_, _), do: nil

  @doc """
  RIPE often stores a nice network name in the remarks.description. This finds it.

  Example:
      iex> response = %RDAP.Response{raw_response: %{remarks: [%{description: ["Derpanet"]}]}}
      ...> Ipdust.RDAPNetworkId.remark_description(response)
      "Derpanet"
  """
  def remark_description(%Response{raw_response: %{remarks: [%{description: [desc | _tail]}]}}) do
    desc
  end
  def remark_description(_), do: nil
end
