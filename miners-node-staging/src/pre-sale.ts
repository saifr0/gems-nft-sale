import {
  AllowedTokenUpdated as AllowedTokenUpdatedEvent,
  BlacklistUpdated as BlacklistUpdatedEvent,
  BuyEnableUpdated as BuyEnableUpdatedEvent,
  MinerFundsWalletUpdated as MinerFundsWalletUpdatedEvent,
  MinerNftPurchased as MinerNftPurchasedEvent,
  MinerNftPurchasedDiscounted as MinerNftPurchasedDiscountedEvent,
  NodeFundsWalletUpdated as NodeFundsWalletUpdatedEvent,
  NodeNftPriceUpdated as NodeNftPriceUpdatedEvent,
  NodeNftPurchased as NodeNftPurchasedEvent,
  OwnershipTransferStarted as OwnershipTransferStartedEvent,
  OwnershipTransferred as OwnershipTransferredEvent,
  PriceAccretionPercentageUpdated as PriceAccretionPercentageUpdatedEvent,
  SignerUpdated as SignerUpdatedEvent,
  TokenRegistryUpdated as TokenRegistryUpdatedEvent
} from "../generated/PreSale/PreSale"
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
  TokenRegistryUpdated, MinerNft
} from "../generated/schema"
import { BigInt, Bytes } from "@graphprotocol/graph-ts"

export function handleAllowedTokenUpdated(
  event: AllowedTokenUpdatedEvent
): void {
  let entity = new AllowedTokenUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.token = event.params.token
  entity.status = event.params.status

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

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

export function handleMinerFundsWalletUpdated(
  event: MinerFundsWalletUpdatedEvent
): void {
  let entity = new MinerFundsWalletUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldMinerFundsWallet = event.params.oldMinerFundsWallet
  entity.newMinerFundsWallet = event.params.newMinerFundsWallet

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleMinerNftPurchased(event: MinerNftPurchasedEvent): void {
  let entity = new MinerNftPurchased(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.token = event.params.token
  entity.tokenPrice = event.params.tokenPrice
  entity.by = event.params.by
  entity.minerPrices = event.params.minerPrices
  entity.quantities = event.params.quantities
  entity.amountPurchased = event.params.amountPurchased

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()

  let _id = event.transaction.hash.concatI32(event.logIndex.toI32())
  let _minerNft = new MinerNft(_id);
  _minerNft.token = event.params.token
  _minerNft.minerPrices = event.params.minerPrices
  _minerNft.tokenPrice = event.params.tokenPrice
  _minerNft.by = event.params.by
  _minerNft.quantities = event.params.quantities
  _minerNft.code = ""
  _minerNft.amountPurchased = event.params.amountPurchased
  _minerNft.leaders = changetype<Bytes[]>([])
  _minerNft.percentages = []
  _minerNft.blockNumber = event.block.number
  _minerNft.blockTimestamp = event.block.timestamp
  _minerNft.transactionHash = event.transaction.hash
  _minerNft.save();

}

export function handleMinerNftPurchasedDiscounted(
  event: MinerNftPurchasedDiscountedEvent
): void {
  let entity = new MinerNftPurchasedDiscounted(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.token = event.params.token
  entity.tokenPrice = event.params.tokenPrice
  entity.by = event.params.by
  entity.minerPrices = event.params.minerPrices
  entity.quantities = event.params.quantities
  entity.code = event.params.code
  entity.amountPurchased = event.params.amountPurchased
  entity.leaders = changetype<Bytes[]>(event.params.leaders)
  entity.percentages = event.params.percentages

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()

  let _id = event.transaction.hash.concatI32(event.logIndex.toI32())
  let _minerNft = new MinerNft(_id);
  _minerNft.token = event.params.token
  _minerNft.tokenPrice = event.params.tokenPrice
  let minerPrices = event.params.minerPrices;
  let empMinerPrices: BigInt[] = [];

  for (let i = 0; i < 3; i++) {
    empMinerPrices[i] = minerPrices[i].times(BigInt.fromI32(500000)).div(BigInt.fromI32(1000000))
  }

  _minerNft.minerPrices = empMinerPrices
  _minerNft.by = event.params.by
  _minerNft.quantities = event.params.quantities
  _minerNft.code = event.params.code
  _minerNft.amountPurchased = event.params.amountPurchased
  _minerNft.leaders = changetype<Bytes[]>(event.params.leaders)
  _minerNft.percentages = event.params.percentages

  _minerNft.blockNumber = event.block.number
  _minerNft.blockTimestamp = event.block.timestamp
  _minerNft.transactionHash = event.transaction.hash
  _minerNft.save();
}

export function handleNodeFundsWalletUpdated(
  event: NodeFundsWalletUpdatedEvent
): void {
  let entity = new NodeFundsWalletUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldNodeFundsWallet = event.params.oldNodeFundsWallet
  entity.newNodeFundsWallet = event.params.newNodeFundsWallet

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNodeNftPriceUpdated(
  event: NodeNftPriceUpdatedEvent
): void {
  let entity = new NodeNftPriceUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldPrice = event.params.oldPrice
  entity.newPrice = event.params.newPrice

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNodeNftPurchased(event: NodeNftPurchasedEvent): void {
  let entity = new NodeNftPurchased(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.token = event.params.token
  entity.tokenPrice = event.params.tokenPrice
  entity.by = event.params.by
  entity.amountPurchased = event.params.amountPurchased
  entity.quantity = event.params.quantity

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

export function handlePriceAccretionPercentageUpdated(
  event: PriceAccretionPercentageUpdatedEvent
): void {
  let entity = new PriceAccretionPercentageUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.oldPriceAccretionPercent = event.params.oldPriceAccretionPercent
  entity.newPriceAccretionPercent = event.params.newPriceAccretionPercent

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
