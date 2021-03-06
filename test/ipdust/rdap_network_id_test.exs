defmodule Ipdust.RDAPNetworkIdTest do
  use ExUnit.Case, async: true
  doctest Ipdust.RDAPNetworkId

  alias Ipdust.RDAPNetworkId
  alias RDAP.{Entity, Response, VCard}

  test "finds registrant entity without nesting" do
    response = %Response{
      entities: [
        %Entity{
          roles: ["registrant"],
          vcard: %VCard{formatted_name: "DerpaNet"}
        }
      ]
    }

    assert %Entity{vcard: %VCard{formatted_name: "DerpaNet"}} =
             RDAPNetworkId.entity_with_role(response, "registrant")
  end

  test "finds registrant when nested" do
    response = %Response{
      entities: [
        %Entity{
          roles: ["abuse"],
          vcard: %VCard{formatted_name: "DerpaNet Abuse"},
          entities: [
            %Entity{
              roles: ["technical"],
              vcard: %VCard{formatted_name: "DerpaNet Administrator"}
            },
            %Entity{
              roles: ["registrant"],
              vcard: %VCard{formatted_name: "DerpaNet"}
            }
          ]
        }
      ]
    }

    assert %Entity{vcard: %VCard{formatted_name: "DerpaNet"}} =
             RDAPNetworkId.entity_with_role(response, "registrant")
  end

  test "returns nil when no registrant available" do
    response = %Response{
      entities: [
        %Entity{
          roles: ["abuse"],
          vcard: %VCard{formatted_name: "DerpaNet Abuse"}
        }
      ]
    }

    assert nil == RDAPNetworkId.entity_with_role(response, "registrant")
  end

  test "finds the description in the remarks" do
    response = %Response{
      raw_response: %{
        remarks: [%{description: ["Derpanet"]}]
      }
    }

    assert "Derpanet" == RDAPNetworkId.remark_description(response)
  end

  test "finds the description in the remarks when there are multiple descriptors" do
    response = %Response{
      raw_response: %{
        remarks: [%{description: ["Derpanet", "More info"]}]
      }
    }

    assert "Derpanet" == RDAPNetworkId.remark_description(response)
  end

  test "given a response with a registrant, uses it" do
    response = %Response{
      entities: [
        %Entity{
          roles: ["registrant"],
          vcard: %VCard{formatted_name: "DerpaNet"}
        }
      ]
    }

    assert "DerpaNet" = RDAPNetworkId.identify(response)
  end

  test "given a response with no registratnt but a remark description, uses it" do
    response = %Response{
      entities: [
        %Entity{
          roles: ["abuse"],
          vcard: %VCard{formatted_name: "DerpaNet Abuse"}
        }
      ],
      raw_response: %{
        remarks: [%{description: ["Derpanet"]}]
      }
    }

    assert "Derpanet" = RDAPNetworkId.identify(response)
  end

  test "uses the network name if avaialble" do
    response = %Response{
      entities: [
        %Entity{
          roles: ["abuse"],
          vcard: %VCard{formatted_name: "Abuse"}
        }
      ],
      raw_response: %{
        name: "Derpanet"
      }
    }

    assert "Derpanet" = RDAPNetworkId.identify(response)
  end
end
