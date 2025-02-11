import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { BlacklistUpdated } from "../generated/schema"
import { BlacklistUpdated as BlacklistUpdatedEvent } from "../generated/PreSale/PreSale"
import { handleBlacklistUpdated } from "../src/pre-sale"
import { createBlacklistUpdatedEvent } from "./pre-sale-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let which = Address.fromString("0x0000000000000000000000000000000000000001")
    let accessNow = "boolean Not implemented"
    let newBlacklistUpdatedEvent = createBlacklistUpdatedEvent(which, accessNow)
    handleBlacklistUpdated(newBlacklistUpdatedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("BlacklistUpdated created and stored", () => {
    assert.entityCount("BlacklistUpdated", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "BlacklistUpdated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "which",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "BlacklistUpdated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "accessNow",
      "boolean Not implemented"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
