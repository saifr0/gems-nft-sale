import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  AllowedTokenUpdated,
  BlacklistUpdated,
  BuyEnableUpdated,
  MinerFundsWalletUpdated,
  MinerNftPurchased,
  MinerNftPurchasedDiscounted,
  NodeFundsWalletUpdated,
  NodeNftPriceUpdated,
  NodeNftPurchased,
  OwnershipTransferStarted,
  OwnershipTransferred,
  PriceAccretionPercentageUpdated,
  SignerUpdated,
  TokenRegistryUpdated
} from "../generated/PreSale/PreSale"

export function createAllowedTokenUpdatedEvent(
  token: Address,
  status: boolean
): AllowedTokenUpdated {
  let allowedTokenUpdatedEvent = changetype<AllowedTokenUpdated>(newMockEvent())

  allowedTokenUpdatedEvent.parameters = new Array()

  allowedTokenUpdatedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  allowedTokenUpdatedEvent.parameters.push(
    new ethereum.EventParam("status", ethereum.Value.fromBoolean(status))
  )

  return allowedTokenUpdatedEvent
}

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

export function createMinerFundsWalletUpdatedEvent(
  oldMinerFundsWallet: Address,
  newMinerFundsWallet: Address
): MinerFundsWalletUpdated {
  let minerFundsWalletUpdatedEvent =
    changetype<MinerFundsWalletUpdated>(newMockEvent())

  minerFundsWalletUpdatedEvent.parameters = new Array()

  minerFundsWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldMinerFundsWallet",
      ethereum.Value.fromAddress(oldMinerFundsWallet)
    )
  )
  minerFundsWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newMinerFundsWallet",
      ethereum.Value.fromAddress(newMinerFundsWallet)
    )
  )

  return minerFundsWalletUpdatedEvent
}

export function createMinerNftPurchasedEvent(
  token: Address,
  tokenPrice: BigInt,
  by: Address,
  minerPrices: Array<BigInt>,
  quantities: Array<BigInt>,
  amountPurchased: BigInt
): MinerNftPurchased {
  let minerNftPurchasedEvent = changetype<MinerNftPurchased>(newMockEvent())

  minerNftPurchasedEvent.parameters = new Array()

  minerNftPurchasedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
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
  token: Address,
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
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
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

export function createNodeFundsWalletUpdatedEvent(
  oldNodeFundsWallet: Address,
  newNodeFundsWallet: Address
): NodeFundsWalletUpdated {
  let nodeFundsWalletUpdatedEvent =
    changetype<NodeFundsWalletUpdated>(newMockEvent())

  nodeFundsWalletUpdatedEvent.parameters = new Array()

  nodeFundsWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldNodeFundsWallet",
      ethereum.Value.fromAddress(oldNodeFundsWallet)
    )
  )
  nodeFundsWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newNodeFundsWallet",
      ethereum.Value.fromAddress(newNodeFundsWallet)
    )
  )

  return nodeFundsWalletUpdatedEvent
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
  token: Address,
  tokenPrice: BigInt,
  by: Address,
  amountPurchased: BigInt,
  quantity: BigInt
): NodeNftPurchased {
  let nodeNftPurchasedEvent = changetype<NodeNftPurchased>(newMockEvent())

  nodeNftPurchasedEvent.parameters = new Array()

  nodeNftPurchasedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
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

export function createPriceAccretionPercentageUpdatedEvent(
  oldPriceAccretionPercent: BigInt,
  newPriceAccretionPercent: BigInt
): PriceAccretionPercentageUpdated {
  let priceAccretionPercentageUpdatedEvent =
    changetype<PriceAccretionPercentageUpdated>(newMockEvent())

  priceAccretionPercentageUpdatedEvent.parameters = new Array()

  priceAccretionPercentageUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldPriceAccretionPercent",
      ethereum.Value.fromUnsignedBigInt(oldPriceAccretionPercent)
    )
  )
  priceAccretionPercentageUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newPriceAccretionPercent",
      ethereum.Value.fromUnsignedBigInt(newPriceAccretionPercent)
    )
  )

  return priceAccretionPercentageUpdatedEvent
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
