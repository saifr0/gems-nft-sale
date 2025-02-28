import {
  BlacklistUpdated as BlacklistUpdatedEvent,
  BuyEnableUpdated as BuyEnableUpdatedEvent,
  InsuranceFundsWalletUpdated as InsuranceFundsWalletUpdatedEvent,
  InsurancePurchased as InsurancePurchasedEvent,
  MinerNftUpdated as MinerNftUpdatedEvent,
  OwnershipTransferStarted as OwnershipTransferStartedEvent,
  OwnershipTransferred as OwnershipTransferredEvent,
  SignerUpdated as SignerUpdatedEvent,
  TokenRegistryUpdated as TokenRegistryUpdatedEvent
} from "../generated/Insurance/Insurance"
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
} from "../generated/schema"

export function handleBlacklistUpdated(event: BlacklistUpdatedEvent): void {
  let entity = new BlacklistUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.which = event.params.which
  entity.accessNow = event.params.accessNow

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleBuyEnableUpdated(event: BuyEnableUpdatedEvent): void {
  let entity = new BuyEnableUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldAccess = event.params.oldAccess
  entity.newAccess = event.params.newAccess

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleInsuranceFundsWalletUpdated(
  event: InsuranceFundsWalletUpdatedEvent
): void {
  let entity = new InsuranceFundsWalletUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldInsuranceFundsWallet = event.params.oldInsuranceFundsWallet
  entity.newInsuranceFundsWallet = event.params.newInsuranceFundsWallet

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleInsurancePurchased(event: InsurancePurchasedEvent): void {
  let entity = new InsurancePurchased(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.token = event.params.token
  entity.by = event.params.by
  entity.quantities = event.params.quantities
  entity.insuranceAmount = event.params.insuranceAmount
  entity.trxHash = event.params.trxHash

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleMinerNftUpdated(event: MinerNftUpdatedEvent): void {
  let entity = new MinerNftUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldMinerNft = event.params.oldMinerNft
  entity.newMinerNft = event.params.newMinerNft

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleOwnershipTransferStarted(
  event: OwnershipTransferStartedEvent
): void {
  let entity = new OwnershipTransferStarted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleSignerUpdated(event: SignerUpdatedEvent): void {
  let entity = new SignerUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldSigner = event.params.oldSigner
  entity.newSigner = event.params.newSigner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleTokenRegistryUpdated(
  event: TokenRegistryUpdatedEvent
): void {
  let entity = new TokenRegistryUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldTokenRegistry = event.params.oldTokenRegistry
  entity.newTokenRegistry = event.params.newTokenRegistry

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
