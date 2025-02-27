import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  BlacklistUpdated,
  BuyEnableUpdated,
  InsuranceFundsWalletUpdated,
  InsurancePurchased,
  MinerNftUpdated,
  OwnershipTransferStarted,
  OwnershipTransferred,
  SignerUpdated,
  TokenRegistryUpdated
} from "../generated/Insurance/Insurance"

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

export function createInsuranceFundsWalletUpdatedEvent(
  oldInsuranceFundsWallet: Address,
  newInsuranceFundsWallet: Address
): InsuranceFundsWalletUpdated {
  let insuranceFundsWalletUpdatedEvent =
    changetype<InsuranceFundsWalletUpdated>(newMockEvent())

  insuranceFundsWalletUpdatedEvent.parameters = new Array()

  insuranceFundsWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldInsuranceFundsWallet",
      ethereum.Value.fromAddress(oldInsuranceFundsWallet)
    )
  )
  insuranceFundsWalletUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newInsuranceFundsWallet",
      ethereum.Value.fromAddress(newInsuranceFundsWallet)
    )
  )

  return insuranceFundsWalletUpdatedEvent
}

export function createInsurancePurchasedEvent(
  token: Address,
  by: Address,
  quantities: Array<BigInt>,
  insuranceAmount: BigInt,
  trxHash: string
): InsurancePurchased {
  let insurancePurchasedEvent = changetype<InsurancePurchased>(newMockEvent())

  insurancePurchasedEvent.parameters = new Array()

  insurancePurchasedEvent.parameters.push(
    new ethereum.EventParam("token", ethereum.Value.fromAddress(token))
  )
  insurancePurchasedEvent.parameters.push(
    new ethereum.EventParam("by", ethereum.Value.fromAddress(by))
  )
  insurancePurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "quantities",
      ethereum.Value.fromUnsignedBigIntArray(quantities)
    )
  )
  insurancePurchasedEvent.parameters.push(
    new ethereum.EventParam(
      "insuranceAmount",
      ethereum.Value.fromUnsignedBigInt(insuranceAmount)
    )
  )
  insurancePurchasedEvent.parameters.push(
    new ethereum.EventParam("trxHash", ethereum.Value.fromString(trxHash))
  )

  return insurancePurchasedEvent
}

export function createMinerNftUpdatedEvent(
  oldMinerNft: Address,
  newMinerNft: Address
): MinerNftUpdated {
  let minerNftUpdatedEvent = changetype<MinerNftUpdated>(newMockEvent())

  minerNftUpdatedEvent.parameters = new Array()

  minerNftUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "oldMinerNft",
      ethereum.Value.fromAddress(oldMinerNft)
    )
  )
  minerNftUpdatedEvent.parameters.push(
    new ethereum.EventParam(
      "newMinerNft",
      ethereum.Value.fromAddress(newMinerNft)
    )
  )

  return minerNftUpdatedEvent
}

export function createOwnershipTransferStartedEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferStarted {
  let ownershipTransferStartedEvent = changetype<OwnershipTransferStarted>(
    newMockEvent()
  )

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
  let ownershipTransferredEvent = changetype<OwnershipTransferred>(
    newMockEvent()
  )

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
  let tokenRegistryUpdatedEvent = changetype<TokenRegistryUpdated>(
    newMockEvent()
  )

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
