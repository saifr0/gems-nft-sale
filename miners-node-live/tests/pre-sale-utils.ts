import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  BlacklistUpdated,
  BuyEnableUpdated,
  MinerNftPurchased,
  MinerNftPurchasedDiscounted,
  NodeNftPriceUpdated,
  NodeNftPurchased,
  OwnershipTransferStarted,
  OwnershipTransferred,
  ProjectWalletUpdated,
  SignerUpdated,
  TokenRegistryUpdated
} from "../generated/PreSale/PreSale"

export function createBlacklistUpdatedEvent(
  which: Address,
  accessNow: boolean
): BlacklistUpdated {
  let blacklistUpdatedEvent = changetype<BlacklistUpdated>(newMockEvent())

  blacklistUpdatedEvent.parameters = new Array()

  blacklistUpdatedEvent.parameters.push(
    new ethereum.EventParam("which", ethereum.Value.fromAddress(which))
  )
  blacklistUpdatedEvent.parameters.push(
    new ethereum.EventParam("accessNow", ethereum.Value.fromBoolean(accessNow))
  )

  return blacklistUpdatedEvent
}

export function createBuyEnableUpdatedEvent(
  oldAccess: boolean,
  newAccess: boolean
): BuyEnableUpdated {
  let buyEnableUpdatedEvent = changetype<BuyEnableUpdated>(newMockEvent())

  buyEnableUpdatedEvent.parameters = new Array()

  buyEnableUpdatedEvent.parameters.push(
    new ethereum.EventParam("oldAccess", ethereum.Value.fromBoolean(oldAccess))
  )
  buyEnableUpdatedEvent.parameters.push(
    new ethereum.EventParam("newAccess", ethereum.Value.fromBoolean(newAccess))
  )

  return buyEnableUpdatedEvent
}

export function createMinerNftPurchasedEvent(
  tokenPrice: BigInt,
  by: Address,
  minerPrices: Array<BigInt>,
  quantities: Array<BigInt>,
  amountPurchased: BigInt
): MinerNftPurchased {
  let minerNftPurchasedEvent = changetype<MinerNftPurchased>(newMockEvent())

  minerNftPurchasedEvent.parameters = new Array()

  minerNftPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "tokenPrice",
      ethereum.Value.fromUnsignedBigInt(tokenPrice)
    )
  )
  minerNftPurchasedEvent.parameters.push(
    new ethereum.EventParam("by", ethereum.Value.fromAddress(by))
  )
  minerNftPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "minerPrices",
      ethereum.Value.fromUnsignedBigIntArray(minerPrices)
    )
  )
  minerNftPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "quantities",
      ethereum.Value.fromUnsignedBigIntArray(quantities)
    )
  )
  minerNftPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "amountPurchased",
      ethereum.Value.fromUnsignedBigInt(amountPurchased)
    )
  )

  return minerNftPurchasedEvent
}

export function createMinerNftPurchasedDiscountedEvent(
  tokenPrice: BigInt,
  by: Address,
  minerPrices: Array<BigInt>,
  quantities: Array<BigInt>,
  code: string,
  amountPurchased: BigInt,
  leaders: Array<Address>,
  percentages: Array<BigInt>
): MinerNftPurchasedDiscounted {
  let minerNftPurchasedDiscountedEvent =
    changetype<MinerNftPurchasedDiscounted>(newMockEvent())

  minerNftPurchasedDiscountedEvent.parameters = new Array()

  minerNftPurchasedDiscountedEvent.parameters.push(
    new ethereum.EventParam(
      "tokenPrice",
      ethereum.Value.fromUnsignedBigInt(tokenPrice)
    )
  )
  minerNftPurchasedDiscountedEvent.parameters.push(
    new ethereum.EventParam("by", ethereum.Value.fromAddress(by))
  )
  minerNftPurchasedDiscountedEvent.parameters.push(
    new ethereum.EventParam(
      "minerPrices",
      ethereum.Value.fromUnsignedBigIntArray(minerPrices)
    )
  )
  minerNftPurchasedDiscountedEvent.parameters.push(
    new ethereum.EventParam(
      "quantities",
      ethereum.Value.fromUnsignedBigIntArray(quantities)
    )
  )
  minerNftPurchasedDiscountedEvent.parameters.push(
    new ethereum.EventParam("code", ethereum.Value.fromString(code))
  )
  minerNftPurchasedDiscountedEvent.parameters.push(
    new ethereum.EventParam(
      "amountPurchased",
      ethereum.Value.fromUnsignedBigInt(amountPurchased)
    )
  )
  minerNftPurchasedDiscountedEvent.parameters.push(
    new ethereum.EventParam("leaders", ethereum.Value.fromAddressArray(leaders))
  )
  minerNftPurchasedDiscountedEvent.parameters.push(
    new ethereum.EventParam(
      "percentages",
      ethereum.Value.fromUnsignedBigIntArray(percentages)
    )
  )

  return minerNftPurchasedDiscountedEvent
}

export function createNodeNftPriceUpdatedEvent(
  oldPrice: BigInt,
  newPrice: BigInt
): NodeNftPriceUpdated {
  let nodeNftPriceUpdatedEvent = changetype<NodeNftPriceUpdated>(newMockEvent())

  nodeNftPriceUpdatedEvent.parameters = new Array()

  nodeNftPriceUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldPrice",
      ethereum.Value.fromUnsignedBigInt(oldPrice)
    )
  )
  nodeNftPriceUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newPrice",
      ethereum.Value.fromUnsignedBigInt(newPrice)
    )
  )

  return nodeNftPriceUpdatedEvent
}

export function createNodeNftPurchasedEvent(
  tokenPrice: BigInt,
  by: Address,
  amountPurchased: BigInt,
  quantity: BigInt
): NodeNftPurchased {
  let nodeNftPurchasedEvent = changetype<NodeNftPurchased>(newMockEvent())

  nodeNftPurchasedEvent.parameters = new Array()

  nodeNftPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "tokenPrice",
      ethereum.Value.fromUnsignedBigInt(tokenPrice)
    )
  )
  nodeNftPurchasedEvent.parameters.push(
    new ethereum.EventParam("by", ethereum.Value.fromAddress(by))
  )
  nodeNftPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "amountPurchased",
      ethereum.Value.fromUnsignedBigInt(amountPurchased)
    )
  )
  nodeNftPurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "quantity",
      ethereum.Value.fromUnsignedBigInt(quantity)
    )
  )

  return nodeNftPurchasedEvent
}

export function createOwnershipTransferStartedEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferStarted {
  let ownershipTransferStartedEvent =
    changetype<OwnershipTransferStarted>(newMockEvent())

  ownershipTransferStartedEvent.parameters = new Array()

  ownershipTransferStartedEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferStartedEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferStartedEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent =
    changetype<OwnershipTransferred>(newMockEvent())

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}

export function createProjectWalletUpdatedEvent(
  oldProjectWallet: Address,
  newProjectWallet: Address
): ProjectWalletUpdated {
  let projectWalletUpdatedEvent =
    changetype<ProjectWalletUpdated>(newMockEvent())

  projectWalletUpdatedEvent.parameters = new Array()

  projectWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldProjectWallet",
      ethereum.Value.fromAddress(oldProjectWallet)
    )
  )
  projectWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newProjectWallet",
      ethereum.Value.fromAddress(newProjectWallet)
    )
  )

  return projectWalletUpdatedEvent
}

export function createSignerUpdatedEvent(
  oldSigner: Address,
  newSigner: Address
): SignerUpdated {
  let signerUpdatedEvent = changetype<SignerUpdated>(newMockEvent())

  signerUpdatedEvent.parameters = new Array()

  signerUpdatedEvent.parameters.push(
    new ethereum.EventParam("oldSigner", ethereum.Value.fromAddress(oldSigner))
  )
  signerUpdatedEvent.parameters.push(
    new ethereum.EventParam("newSigner", ethereum.Value.fromAddress(newSigner))
  )

  return signerUpdatedEvent
}

export function createTokenRegistryUpdatedEvent(
  oldTokenRegistry: Address,
  newTokenRegistry: Address
): TokenRegistryUpdated {
  let tokenRegistryUpdatedEvent =
    changetype<TokenRegistryUpdated>(newMockEvent())

  tokenRegistryUpdatedEvent.parameters = new Array()

  tokenRegistryUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldTokenRegistry",
      ethereum.Value.fromAddress(oldTokenRegistry)
    )
  )
  tokenRegistryUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newTokenRegistry",
      ethereum.Value.fromAddress(newTokenRegistry)
    )
  )

  return tokenRegistryUpdatedEvent
}
