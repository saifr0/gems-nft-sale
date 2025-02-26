import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as"
import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts"
import { ClaimRevoked } from "../generated/schema"
import { ClaimRevoked as ClaimRevokedEvent } from "../generated/Claims/Claims"
import { handleClaimRevoked } from "../src/claims"
import { createClaimRevokedEvent } from "./claims-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let leader = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let token = Address.fromString("0x0000000000000000000000000000000000000001")
    let amount = BigInt.fromI32(234)
    let newClaimRevokedEvent = createClaimRevokedEvent(leader, token, amount)
    handleClaimRevoked(newClaimRevokedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("ClaimRevoked created and stored", () => {
    assert.entityCount("ClaimRevoked", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "ClaimRevoked",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "leader",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "ClaimRevoked",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "token",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "ClaimRevoked",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "amount",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
