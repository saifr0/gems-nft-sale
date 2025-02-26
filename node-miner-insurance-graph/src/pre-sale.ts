import { BigInt, Bytes } from '@graphprotocol/graph-ts';
import {
    AllowedTokenUpdated as AllowedTokenUpdatedEvent,
    BlacklistUpdated as BlacklistUpdatedEvent,
    BuyEnableUpdated as BuyEnableUpdatedEvent,
    InsuranceFeeUpdated as InsuranceFeeUpdatedEvent,
    InsuranceFundsWalletUpdated as InsuranceFundsWalletUpdatedEvent,
    MinerFundsWalletUpdated as MinerFundsWalletUpdatedEvent,
    MinerNftPurchasedDiscounted as MinerNftPurchasedDiscountedEvent,
    MinerNftPurchased as MinerNftPurchasedEvent,
    NodeFundsWalletUpdated as NodeFundsWalletUpdatedEvent,
    NodeNftPriceUpdated as NodeNftPriceUpdatedEvent,
    NodeNftPurchased as NodeNftPurchasedEvent,
    OwnershipTransferred as OwnershipTransferredEvent,
    OwnershipTransferStarted as OwnershipTransferStartedEvent,
    PriceAccretionPercentageUpdated as PriceAccretionPercentageUpdatedEvent,
    SignerUpdated as SignerUpdatedEvent,
    TokenRegistryUpdated as TokenRegistryUpdatedEvent
} from '../generated/PreSale/PreSale';
import {
    AllowedTokenUpdated,
    BlacklistUpdated,
    BuyEnableUpdated,
    InsuranceFeeUpdated,
    InsuranceFundsWalletUpdated,
    MinerFundsWalletUpdated,
    MinerNft,
    MinerNftPurchased,
    MinerNftPurchasedDiscounted,
    NodeFundsWalletUpdated,
    NodeNftPriceUpdated,
    NodeNftPurchased,
    OwnershipTransferred,
    OwnershipTransferStarted,
    PriceAccretionPercentageUpdated,
    SignerUpdated,
    TokenRegistryUpdated
} from '../generated/schema';

export function handleAllowedTokenUpdated(event: AllowedTokenUpdatedEvent): void {
    let entity = new AllowedTokenUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.token = event.params.token;
    entity.status = event.params.status;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleBlacklistUpdated(event: BlacklistUpdatedEvent): void {
    let entity = new BlacklistUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.which = event.params.which;
    entity.accessNow = event.params.accessNow;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleBuyEnableUpdated(event: BuyEnableUpdatedEvent): void {
    let entity = new BuyEnableUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldAccess = event.params.oldAccess;
    entity.newAccess = event.params.newAccess;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleInsuranceFeeUpdated(event: InsuranceFeeUpdatedEvent): void {
    let entity = new InsuranceFeeUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldInsuranceFee = event.params.oldInsuranceFee;
    entity.newInsuranceFee = event.params.newInsuranceFee;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleInsuranceFundsWalletUpdated(event: InsuranceFundsWalletUpdatedEvent): void {
    let entity = new InsuranceFundsWalletUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldInsuranceFundsWallet = event.params.oldInsuranceFundsWallet;
    entity.newInsuranceFundsWallet = event.params.newInsuranceFundsWallet;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleMinerFundsWalletUpdated(event: MinerFundsWalletUpdatedEvent): void {
    let entity = new MinerFundsWalletUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldMinerFundsWallet = event.params.oldMinerFundsWallet;
    entity.newMinerFundsWallet = event.params.newMinerFundsWallet;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleMinerNftPurchased(event: MinerNftPurchasedEvent): void {
    let entity = new MinerNftPurchased(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.token = event.params.token;
    entity.tokenPrice = event.params.tokenPrice;
    entity.by = event.params.by;
    entity.minerPrices = event.params.minerPrices;
    entity.quantities = event.params.quantities;
    entity.amountPurchased = event.params.amountPurchased;
    entity.isInsured = event.params.isInsured;
    entity.insuranceAmount = event.params.insuranceAmount;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();

    let _id = event.transaction.hash.concatI32(event.logIndex.toI32());
    let _purchased = new MinerNft(_id);

    _purchased.token = event.params.token;
    _purchased.tokenPrice = event.params.tokenPrice;
    _purchased.by = event.params.by;
    _purchased.minerPrices = event.params.minerPrices;
    _purchased.quantities = event.params.quantities;
    _purchased.code = '';
    _purchased.amountPurchased = event.params.amountPurchased;
    _purchased.leaders = [];
    _purchased.percentages = [];
    _purchased.discountPercentage = BigInt.fromI32(0);
    _purchased.blockNumber = event.block.number;
    _purchased.blockTimestamp = event.block.timestamp;
    _purchased.isInsured = event.params.isInsured;
    _purchased.insuranceAmount = event.params.insuranceAmount;
    _purchased.transactionHash = event.transaction.hash;
    _purchased.save();
}

export function handleMinerNftPurchasedDiscounted(event: MinerNftPurchasedDiscountedEvent): void {
    let entity = new MinerNftPurchasedDiscounted(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.token = event.params.token;
    entity.tokenPrice = event.params.tokenPrice;
    entity.by = event.params.by;
    entity.minerPrices = event.params.minerPrices;
    entity.quantities = event.params.quantities;
    entity.code = event.params.code;
    entity.amountPurchased = event.params.amountPurchased;
    entity.leaders = changetype<Bytes[]>(event.params.leaders);
    entity.percentages = event.params.percentages;
    entity.discountPercentage = event.params.discountPercentage;
    entity.isInsured = event.params.isInsured;
    entity.insuranceAmount = event.params.insuranceAmount;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();

    let _id = event.transaction.hash.concatI32(event.logIndex.toI32());
    let _purchased = new MinerNft(_id);

    _purchased.token = event.params.token;
    _purchased.tokenPrice = event.params.tokenPrice;
    _purchased.by = event.params.by;

    let minerPricesInit = event.params.minerPrices;
    let discountedMinerPrices: BigInt[] = [];

    for (let i = 0; i < minerPricesInit.length; i++) {
        discountedMinerPrices[i] = minerPricesInit[i]
            .times(event.params.discountPercentage)
            .div(BigInt.fromI32(1000000));
    }

    _purchased.minerPrices = discountedMinerPrices;

    _purchased.quantities = event.params.quantities;
    _purchased.code = event.params.code;
    _purchased.amountPurchased = event.params.amountPurchased;
    _purchased.leaders = changetype<Bytes[]>(event.params.leaders);
    _purchased.percentages = event.params.percentages;
    _purchased.discountPercentage = event.params.discountPercentage;

    _purchased.blockNumber = event.block.number;
    _purchased.blockTimestamp = event.block.timestamp;
    _purchased.isInsured = event.params.isInsured;
    _purchased.insuranceAmount = event.params.insuranceAmount;
    _purchased.transactionHash = event.transaction.hash;
    _purchased.save();
}

export function handleNodeFundsWalletUpdated(event: NodeFundsWalletUpdatedEvent): void {
    let entity = new NodeFundsWalletUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldNodeFundsWallet = event.params.oldNodeFundsWallet;
    entity.newNodeFundsWallet = event.params.newNodeFundsWallet;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleNodeNftPriceUpdated(event: NodeNftPriceUpdatedEvent): void {
    let entity = new NodeNftPriceUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldPrice = event.params.oldPrice;
    entity.newPrice = event.params.newPrice;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleNodeNftPurchased(event: NodeNftPurchasedEvent): void {
    let entity = new NodeNftPurchased(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.token = event.params.token;
    entity.tokenPrice = event.params.tokenPrice;
    entity.by = event.params.by;
    entity.amountPurchased = event.params.amountPurchased;
    entity.quantity = event.params.quantity;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleOwnershipTransferStarted(event: OwnershipTransferStartedEvent): void {
    let entity = new OwnershipTransferStarted(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.previousOwner = event.params.previousOwner;
    entity.newOwner = event.params.newOwner;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleOwnershipTransferred(event: OwnershipTransferredEvent): void {
    let entity = new OwnershipTransferred(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.previousOwner = event.params.previousOwner;
    entity.newOwner = event.params.newOwner;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handlePriceAccretionPercentageUpdated(event: PriceAccretionPercentageUpdatedEvent): void {
    let entity = new PriceAccretionPercentageUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldPriceAccretionPercent = event.params.oldPriceAccretionPercent;
    entity.newPriceAccretionPercent = event.params.newPriceAccretionPercent;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleSignerUpdated(event: SignerUpdatedEvent): void {
    let entity = new SignerUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldSigner = event.params.oldSigner;
    entity.newSigner = event.params.newSigner;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}

export function handleTokenRegistryUpdated(event: TokenRegistryUpdatedEvent): void {
    let entity = new TokenRegistryUpdated(event.transaction.hash.concatI32(event.logIndex.toI32()));
    entity.oldTokenRegistry = event.params.oldTokenRegistry;
    entity.newTokenRegistry = event.params.newTokenRegistry;

    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
}
