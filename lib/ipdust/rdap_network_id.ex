defmodule Ipdust.RDAPNetworkId do
  @moduledoc """
  Searches through RDAP responses to try to find a friendly network ID such as ISP
  or company name
  """

  alias RDAP.{Entity, Response}

  @doc """
  (This is a bit of a mess and could probably use a refactor)
  Searches for the first registrant in the entities of an RDAP response.

  There seem to be many ways of structuring the entities in an RDAP response based
  on the ownership structure of the network, the NIC, or who knows.

  Sometimes the registrant is the only object. Sometimes it's nested under "abuse"
  or "technical". Why? No idea. So this recursively searches the entities and finds
  the first one with the registrant role
  """
  def entity_with_role(%Response{entities: entities} = _, role) when is_binary(role) do
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
  def remark_description(%Response{raw_response: %{remarks: [%{description: [desc]}]}} = _) do
    desc
  end
  def remark_description(_), do: nil
end
