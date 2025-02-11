import {
  ClaimRevoked as ClaimRevokedEvent,
  ClaimSet as ClaimSetEvent,
  ClaimsUpdated as ClaimsUpdatedEvent,
  FundsClaimed as FundsClaimedEvent,
  FundsWalletUpdated as FundsWalletUpdatedEvent,
  PresaleUpdated as PresaleUpdatedEvent,
  RoleAdminChanged as RoleAdminChangedEvent,
  RoleGranted as RoleGrantedEvent,
  RoleRevoked as RoleRevokedEvent,
} from "../generated/Claims/Claims"
import {
  ClaimRevoked,
  ClaimSet,
  ClaimsUpdated,
  FundsClaimed,
  FundsWalletUpdated,
  PresaleUpdated,
  RoleAdminChanged,
  RoleGranted,
  RoleRevoked,
} from "../generated/schema"

export function handleClaimRevoked(event: ClaimRevokedEvent): void {
  let entity = new ClaimRevoked(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.leader = event.params.leader
  entity.amount = event.params.amount
  entity.week = event.params.week

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleClaimSet(event: ClaimSetEvent): void {
  let entity = new ClaimSet(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.to = event.params.to
  entity.week = event.params.week
  entity.endTime = event.params.endTime
  entity.amount = event.params.amount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleClaimsUpdated(event: ClaimsUpdatedEvent): void {
  let entity = new ClaimsUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.leader = event.params.leader
  entity.amount = event.params.amount
  entity.week = event.params.week

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleFundsClaimed(event: FundsClaimedEvent): void {
  let entity = new FundsClaimed(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.by = event.params.by
  entity.week = event.params.week
  entity.amount = event.params.amount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleFundsWalletUpdated(event: FundsWalletUpdatedEvent): void {
  let entity = new FundsWalletUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.oldFundsWallet = event.params.oldFundsWallet
  entity.newFundsWallet = event.params.newFundsWallet

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handlePresaleUpdated(event: PresaleUpdatedEvent): void {
  let entity = new PresaleUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.prevAddress = event.params.prevAddress
  entity.newAddress = event.params.newAddress

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoleAdminChanged(event: RoleAdminChangedEvent): void {
  let entity = new RoleAdminChanged(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.role = event.params.role
  entity.previousAdminRole = event.params.previousAdminRole
  entity.newAdminRole = event.params.newAdminRole

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoleGranted(event: RoleGrantedEvent): void {
  let entity = new RoleGranted(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.role = event.params.role
  entity.account = event.params.account
  entity.sender = event.params.sender

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleRoleRevoked(event: RoleRevokedEvent): void {
  let entity = new RoleRevoked(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.role = event.params.role
  entity.account = event.params.account
  entity.sender = event.params.sender

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
