// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  ethereum,
  JSONValue,
  TypedMap,
  Entity,
  Bytes,
  Address,
  BigInt,
} from "@graphprotocol/graph-ts";

export class AllowedTokenUpdated extends ethereum.Event {
  get params(): AllowedTokenUpdated__Params {
    return new AllowedTokenUpdated__Params(this);
  }
}

export class AllowedTokenUpdated__Params {
  _event: AllowedTokenUpdated;

  constructor(event: AllowedTokenUpdated) {
    this._event = event;
  }

  get token(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get status(): boolean {
    return this._event.parameters[1].value.toBoolean();
  }
}

export class BlacklistUpdated extends ethereum.Event {
  get params(): BlacklistUpdated__Params {
    return new BlacklistUpdated__Params(this);
  }
}

export class BlacklistUpdated__Params {
  _event: BlacklistUpdated;

  constructor(event: BlacklistUpdated) {
    this._event = event;
  }

  get which(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get accessNow(): boolean {
    return this._event.parameters[1].value.toBoolean();
  }
}

export class BuyEnableUpdated extends ethereum.Event {
  get params(): BuyEnableUpdated__Params {
    return new BuyEnableUpdated__Params(this);
  }
}

export class BuyEnableUpdated__Params {
  _event: BuyEnableUpdated;

  constructor(event: BuyEnableUpdated) {
    this._event = event;
  }

  get oldAccess(): boolean {
    return this._event.parameters[0].value.toBoolean();
  }

  get newAccess(): boolean {
    return this._event.parameters[1].value.toBoolean();
  }
}

export class MinerFundsWalletUpdated extends ethereum.Event {
  get params(): MinerFundsWalletUpdated__Params {
    return new MinerFundsWalletUpdated__Params(this);
  }
}

export class MinerFundsWalletUpdated__Params {
  _event: MinerFundsWalletUpdated;

  constructor(event: MinerFundsWalletUpdated) {
    this._event = event;
  }

  get oldMinerFundsWallet(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get newMinerFundsWallet(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class MinerNftPurchased extends ethereum.Event {
  get params(): MinerNftPurchased__Params {
    return new MinerNftPurchased__Params(this);
  }
}

export class MinerNftPurchased__Params {
  _event: MinerNftPurchased;

  constructor(event: MinerNftPurchased) {
    this._event = event;
  }

  get token(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get tokenPrice(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get by(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get minerPrices(): Array<BigInt> {
    return this._event.parameters[3].value.toBigIntArray();
  }

  get quantities(): Array<BigInt> {
    return this._event.parameters[4].value.toBigIntArray();
  }

  get amountPurchased(): BigInt {
    return this._event.parameters[5].value.toBigInt();
  }
}

export class MinerNftPurchasedDiscounted extends ethereum.Event {
  get params(): MinerNftPurchasedDiscounted__Params {
    return new MinerNftPurchasedDiscounted__Params(this);
  }
}

export class MinerNftPurchasedDiscounted__Params {
  _event: MinerNftPurchasedDiscounted;

  constructor(event: MinerNftPurchasedDiscounted) {
    this._event = event;
  }

  get token(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get tokenPrice(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get by(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get minerPrices(): Array<BigInt> {
    return this._event.parameters[3].value.toBigIntArray();
  }

  get quantities(): Array<BigInt> {
    return this._event.parameters[4].value.toBigIntArray();
  }

  get code(): string {
    return this._event.parameters[5].value.toString();
  }

  get amountPurchased(): BigInt {
    return this._event.parameters[6].value.toBigInt();
  }

  get leaders(): Array<Address> {
    return this._event.parameters[7].value.toAddressArray();
  }

  get percentages(): Array<BigInt> {
    return this._event.parameters[8].value.toBigIntArray();
  }
}

export class NodeFundsWalletUpdated extends ethereum.Event {
  get params(): NodeFundsWalletUpdated__Params {
    return new NodeFundsWalletUpdated__Params(this);
  }
}

export class NodeFundsWalletUpdated__Params {
  _event: NodeFundsWalletUpdated;

  constructor(event: NodeFundsWalletUpdated) {
    this._event = event;
  }

  get oldNodeFundsWallet(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get newNodeFundsWallet(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class NodeNftPriceUpdated extends ethereum.Event {
  get params(): NodeNftPriceUpdated__Params {
    return new NodeNftPriceUpdated__Params(this);
  }
}

export class NodeNftPriceUpdated__Params {
  _event: NodeNftPriceUpdated;

  constructor(event: NodeNftPriceUpdated) {
    this._event = event;
  }

  get oldPrice(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get newPrice(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }
}

export class NodeNftPurchased extends ethereum.Event {
  get params(): NodeNftPurchased__Params {
    return new NodeNftPurchased__Params(this);
  }
}

export class NodeNftPurchased__Params {
  _event: NodeNftPurchased;

  constructor(event: NodeNftPurchased) {
    this._event = event;
  }

  get token(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get tokenPrice(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get by(): Address {
    return this._event.parameters[2].value.toAddress();
  }

  get amountPurchased(): BigInt {
    return this._event.parameters[3].value.toBigInt();
  }

  get quantity(): BigInt {
    return this._event.parameters[4].value.toBigInt();
  }
}

export class OwnershipTransferStarted extends ethereum.Event {
  get params(): OwnershipTransferStarted__Params {
    return new OwnershipTransferStarted__Params(this);
  }
}

export class OwnershipTransferStarted__Params {
  _event: OwnershipTransferStarted;

  constructor(event: OwnershipTransferStarted) {
    this._event = event;
  }

  get previousOwner(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get newOwner(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class OwnershipTransferred extends ethereum.Event {
  get params(): OwnershipTransferred__Params {
    return new OwnershipTransferred__Params(this);
  }
}

export class OwnershipTransferred__Params {
  _event: OwnershipTransferred;

  constructor(event: OwnershipTransferred) {
    this._event = event;
  }

  get previousOwner(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get newOwner(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class PriceAccretionPercentageUpdated extends ethereum.Event {
  get params(): PriceAccretionPercentageUpdated__Params {
    return new PriceAccretionPercentageUpdated__Params(this);
  }
}

export class PriceAccretionPercentageUpdated__Params {
  _event: PriceAccretionPercentageUpdated;

  constructor(event: PriceAccretionPercentageUpdated) {
    this._event = event;
  }

  get oldPriceAccretionPercent(): BigInt {
    return this._event.parameters[0].value.toBigInt();
  }

  get newPriceAccretionPercent(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }
}

export class SignerUpdated extends ethereum.Event {
  get params(): SignerUpdated__Params {
    return new SignerUpdated__Params(this);
  }
}

export class SignerUpdated__Params {
  _event: SignerUpdated;

  constructor(event: SignerUpdated) {
    this._event = event;
  }

  get oldSigner(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get newSigner(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class TokenRegistryUpdated extends ethereum.Event {
  get params(): TokenRegistryUpdated__Params {
    return new TokenRegistryUpdated__Params(this);
  }
}

export class TokenRegistryUpdated__Params {
  _event: TokenRegistryUpdated;

  constructor(event: TokenRegistryUpdated) {
    this._event = event;
  }

  get oldTokenRegistry(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get newTokenRegistry(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class PreSale extends ethereum.SmartContract {
  static bind(address: Address): PreSale {
    return new PreSale("PreSale", address);
  }

  MAX_CAP(): BigInt {
    let result = super.call("MAX_CAP", "MAX_CAP():(uint256)", []);

    return result[0].toBigInt();
  }

  try_MAX_CAP(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("MAX_CAP", "MAX_CAP():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  accretionThreshold(): BigInt {
    let result = super.call(
      "accretionThreshold",
      "accretionThreshold():(uint256)",
      [],
    );

    return result[0].toBigInt();
  }

  try_accretionThreshold(): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "accretionThreshold",
      "accretionThreshold():(uint256)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  allowedTokens(param0: Address): boolean {
    let result = super.call("allowedTokens", "allowedTokens(address):(bool)", [
      ethereum.Value.fromAddress(param0),
    ]);

    return result[0].toBoolean();
  }

  try_allowedTokens(param0: Address): ethereum.CallResult<boolean> {
    let result = super.tryCall(
      "allowedTokens",
      "allowedTokens(address):(bool)",
      [ethereum.Value.fromAddress(param0)],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  blacklistAddress(param0: Address): boolean {
    let result = super.call(
      "blacklistAddress",
      "blacklistAddress(address):(bool)",
      [ethereum.Value.fromAddress(param0)],
    );

    return result[0].toBoolean();
  }

  try_blacklistAddress(param0: Address): ethereum.CallResult<boolean> {
    let result = super.tryCall(
      "blacklistAddress",
      "blacklistAddress(address):(bool)",
      [ethereum.Value.fromAddress(param0)],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  buyEnabled(): boolean {
    let result = super.call("buyEnabled", "buyEnabled():(bool)", []);

    return result[0].toBoolean();
  }

  try_buyEnabled(): ethereum.CallResult<boolean> {
    let result = super.tryCall("buyEnabled", "buyEnabled():(bool)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  claimsContract(): Address {
    let result = super.call("claimsContract", "claimsContract():(address)", []);

    return result[0].toAddress();
  }

  try_claimsContract(): ethereum.CallResult<Address> {
    let result = super.tryCall(
      "claimsContract",
      "claimsContract():(address)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  minerFundsWallet(): Address {
    let result = super.call(
      "minerFundsWallet",
      "minerFundsWallet():(address)",
      [],
    );

    return result[0].toAddress();
  }

  try_minerFundsWallet(): ethereum.CallResult<Address> {
    let result = super.tryCall(
      "minerFundsWallet",
      "minerFundsWallet():(address)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  minerNFTPrices(param0: BigInt): BigInt {
    let result = super.call(
      "minerNFTPrices",
      "minerNFTPrices(uint256):(uint256)",
      [ethereum.Value.fromUnsignedBigInt(param0)],
    );

    return result[0].toBigInt();
  }

  try_minerNFTPrices(param0: BigInt): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "minerNFTPrices",
      "minerNFTPrices(uint256):(uint256)",
      [ethereum.Value.fromUnsignedBigInt(param0)],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  minerNft(): Address {
    let result = super.call("minerNft", "minerNft():(address)", []);

    return result[0].toAddress();
  }

  try_minerNft(): ethereum.CallResult<Address> {
    let result = super.tryCall("minerNft", "minerNft():(address)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  nodeFundsWallet(): Address {
    let result = super.call(
      "nodeFundsWallet",
      "nodeFundsWallet():(address)",
      [],
    );

    return result[0].toAddress();
  }

  try_nodeFundsWallet(): ethereum.CallResult<Address> {
    let result = super.tryCall(
      "nodeFundsWallet",
      "nodeFundsWallet():(address)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  nodeNFTPrice(): BigInt {
    let result = super.call("nodeNFTPrice", "nodeNFTPrice():(uint256)", []);

    return result[0].toBigInt();
  }

  try_nodeNFTPrice(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("nodeNFTPrice", "nodeNFTPrice():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  nodeNft(): Address {
    let result = super.call("nodeNft", "nodeNft():(address)", []);

    return result[0].toAddress();
  }

  try_nodeNft(): ethereum.CallResult<Address> {
    let result = super.tryCall("nodeNft", "nodeNft():(address)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  owner(): Address {
    let result = super.call("owner", "owner():(address)", []);

    return result[0].toAddress();
  }

  try_owner(): ethereum.CallResult<Address> {
    let result = super.tryCall("owner", "owner():(address)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  pendingOwner(): Address {
    let result = super.call("pendingOwner", "pendingOwner():(address)", []);

    return result[0].toAddress();
  }

  try_pendingOwner(): ethereum.CallResult<Address> {
    let result = super.tryCall("pendingOwner", "pendingOwner():(address)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  priceAccretionPercentagePPM(): BigInt {
    let result = super.call(
      "priceAccretionPercentagePPM",
      "priceAccretionPercentagePPM():(uint256)",
      [],
    );

    return result[0].toBigInt();
  }

  try_priceAccretionPercentagePPM(): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "priceAccretionPercentagePPM",
      "priceAccretionPercentagePPM():(uint256)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  signerWallet(): Address {
    let result = super.call("signerWallet", "signerWallet():(address)", []);

    return result[0].toAddress();
  }

  try_signerWallet(): ethereum.CallResult<Address> {
    let result = super.tryCall("signerWallet", "signerWallet():(address)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  tokenRegistry(): Address {
    let result = super.call("tokenRegistry", "tokenRegistry():(address)", []);

    return result[0].toAddress();
  }

  try_tokenRegistry(): ethereum.CallResult<Address> {
    let result = super.tryCall(
      "tokenRegistry",
      "tokenRegistry():(address)",
      [],
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  totalRaised(): BigInt {
    let result = super.call("totalRaised", "totalRaised():(uint256)", []);

    return result[0].toBigInt();
  }

  try_totalRaised(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("totalRaised", "totalRaised():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }
}

export class ConstructorCall extends ethereum.Call {
  get inputs(): ConstructorCall__Inputs {
    return new ConstructorCall__Inputs(this);
  }

  get outputs(): ConstructorCall__Outputs {
    return new ConstructorCall__Outputs(this);
  }
}

export class ConstructorCall__Inputs {
  _call: ConstructorCall;

  constructor(call: ConstructorCall) {
    this._call = call;
  }

  get nodeFundsWalletAddress(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get minerFundsWalletAddress(): Address {
    return this._call.inputValues[1].value.toAddress();
  }

  get signerAddress(): Address {
    return this._call.inputValues[2].value.toAddress();
  }

  get owner(): Address {
    return this._call.inputValues[3].value.toAddress();
  }

  get claimsAddress(): Address {
    return this._call.inputValues[4].value.toAddress();
  }

  get minerNftAddress(): Address {
    return this._call.inputValues[5].value.toAddress();
  }

  get nodeNftAddress(): Address {
    return this._call.inputValues[6].value.toAddress();
  }

  get tokenRegistryAddress(): Address {
    return this._call.inputValues[7].value.toAddress();
  }

  get nodeNftPriceInit(): BigInt {
    return this._call.inputValues[8].value.toBigInt();
  }

  get priceAccretionPercentagePPMInit(): BigInt {
    return this._call.inputValues[9].value.toBigInt();
  }

  get minerNftPricesInit(): Array<BigInt> {
    return this._call.inputValues[10].value.toBigIntArray();
  }
}

export class ConstructorCall__Outputs {
  _call: ConstructorCall;

  constructor(call: ConstructorCall) {
    this._call = call;
  }
}

export class AcceptOwnershipCall extends ethereum.Call {
  get inputs(): AcceptOwnershipCall__Inputs {
    return new AcceptOwnershipCall__Inputs(this);
  }

  get outputs(): AcceptOwnershipCall__Outputs {
    return new AcceptOwnershipCall__Outputs(this);
  }
}

export class AcceptOwnershipCall__Inputs {
  _call: AcceptOwnershipCall;

  constructor(call: AcceptOwnershipCall) {
    this._call = call;
  }
}

export class AcceptOwnershipCall__Outputs {
  _call: AcceptOwnershipCall;

  constructor(call: AcceptOwnershipCall) {
    this._call = call;
  }
}

export class ChangeSignerCall extends ethereum.Call {
  get inputs(): ChangeSignerCall__Inputs {
    return new ChangeSignerCall__Inputs(this);
  }

  get outputs(): ChangeSignerCall__Outputs {
    return new ChangeSignerCall__Outputs(this);
  }
}

export class ChangeSignerCall__Inputs {
  _call: ChangeSignerCall;

  constructor(call: ChangeSignerCall) {
    this._call = call;
  }

  get newSigner(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class ChangeSignerCall__Outputs {
  _call: ChangeSignerCall;

  constructor(call: ChangeSignerCall) {
    this._call = call;
  }
}

export class EnableBuyCall extends ethereum.Call {
  get inputs(): EnableBuyCall__Inputs {
    return new EnableBuyCall__Inputs(this);
  }

  get outputs(): EnableBuyCall__Outputs {
    return new EnableBuyCall__Outputs(this);
  }
}

export class EnableBuyCall__Inputs {
  _call: EnableBuyCall;

  constructor(call: EnableBuyCall) {
    this._call = call;
  }

  get enabled(): boolean {
    return this._call.inputValues[0].value.toBoolean();
  }
}

export class EnableBuyCall__Outputs {
  _call: EnableBuyCall;

  constructor(call: EnableBuyCall) {
    this._call = call;
  }
}

export class PurchaseMinerNFTCall extends ethereum.Call {
  get inputs(): PurchaseMinerNFTCall__Inputs {
    return new PurchaseMinerNFTCall__Inputs(this);
  }

  get outputs(): PurchaseMinerNFTCall__Outputs {
    return new PurchaseMinerNFTCall__Outputs(this);
  }
}

export class PurchaseMinerNFTCall__Inputs {
  _call: PurchaseMinerNFTCall;

  constructor(call: PurchaseMinerNFTCall) {
    this._call = call;
  }

  get token(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get referenceTokenPrice(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }

  get deadline(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }

  get quantities(): Array<BigInt> {
    return this._call.inputValues[3].value.toBigIntArray();
  }

  get referenceNormalizationFactor(): i32 {
    return this._call.inputValues[4].value.toI32();
  }

  get v(): i32 {
    return this._call.inputValues[5].value.toI32();
  }

  get r(): Bytes {
    return this._call.inputValues[6].value.toBytes();
  }

  get s(): Bytes {
    return this._call.inputValues[7].value.toBytes();
  }
}

export class PurchaseMinerNFTCall__Outputs {
  _call: PurchaseMinerNFTCall;

  constructor(call: PurchaseMinerNFTCall) {
    this._call = call;
  }
}

export class PurchaseMinerNFTDiscountCall extends ethereum.Call {
  get inputs(): PurchaseMinerNFTDiscountCall__Inputs {
    return new PurchaseMinerNFTDiscountCall__Inputs(this);
  }

  get outputs(): PurchaseMinerNFTDiscountCall__Outputs {
    return new PurchaseMinerNFTDiscountCall__Outputs(this);
  }
}

export class PurchaseMinerNFTDiscountCall__Inputs {
  _call: PurchaseMinerNFTDiscountCall;

  constructor(call: PurchaseMinerNFTDiscountCall) {
    this._call = call;
  }

  get token(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get referenceTokenPrice(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }

  get deadline(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }

  get quantities(): Array<BigInt> {
    return this._call.inputValues[3].value.toBigIntArray();
  }

  get percentages(): Array<BigInt> {
    return this._call.inputValues[4].value.toBigIntArray();
  }

  get leaders(): Array<Address> {
    return this._call.inputValues[5].value.toAddressArray();
  }

  get referenceNormalizationFactor(): i32 {
    return this._call.inputValues[6].value.toI32();
  }

  get code(): string {
    return this._call.inputValues[7].value.toString();
  }

  get v(): i32 {
    return this._call.inputValues[8].value.toI32();
  }

  get r(): Bytes {
    return this._call.inputValues[9].value.toBytes();
  }

  get s(): Bytes {
    return this._call.inputValues[10].value.toBytes();
  }
}

export class PurchaseMinerNFTDiscountCall__Outputs {
  _call: PurchaseMinerNFTDiscountCall;

  constructor(call: PurchaseMinerNFTDiscountCall) {
    this._call = call;
  }
}

export class PurchaseNodeNFTCall extends ethereum.Call {
  get inputs(): PurchaseNodeNFTCall__Inputs {
    return new PurchaseNodeNFTCall__Inputs(this);
  }

  get outputs(): PurchaseNodeNFTCall__Outputs {
    return new PurchaseNodeNFTCall__Outputs(this);
  }
}

export class PurchaseNodeNFTCall__Inputs {
  _call: PurchaseNodeNFTCall;

  constructor(call: PurchaseNodeNFTCall) {
    this._call = call;
  }

  get token(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get quantity(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }

  get referenceTokenPrice(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }

  get deadline(): BigInt {
    return this._call.inputValues[3].value.toBigInt();
  }

  get referenceNormalizationFactor(): i32 {
    return this._call.inputValues[4].value.toI32();
  }

  get v(): i32 {
    return this._call.inputValues[5].value.toI32();
  }

  get r(): Bytes {
    return this._call.inputValues[6].value.toBytes();
  }

  get s(): Bytes {
    return this._call.inputValues[7].value.toBytes();
  }
}

export class PurchaseNodeNFTCall__Outputs {
  _call: PurchaseNodeNFTCall;

  constructor(call: PurchaseNodeNFTCall) {
    this._call = call;
  }
}

export class RenounceOwnershipCall extends ethereum.Call {
  get inputs(): RenounceOwnershipCall__Inputs {
    return new RenounceOwnershipCall__Inputs(this);
  }

  get outputs(): RenounceOwnershipCall__Outputs {
    return new RenounceOwnershipCall__Outputs(this);
  }
}

export class RenounceOwnershipCall__Inputs {
  _call: RenounceOwnershipCall;

  constructor(call: RenounceOwnershipCall) {
    this._call = call;
  }
}

export class RenounceOwnershipCall__Outputs {
  _call: RenounceOwnershipCall;

  constructor(call: RenounceOwnershipCall) {
    this._call = call;
  }
}

export class TransferOwnershipCall extends ethereum.Call {
  get inputs(): TransferOwnershipCall__Inputs {
    return new TransferOwnershipCall__Inputs(this);
  }

  get outputs(): TransferOwnershipCall__Outputs {
    return new TransferOwnershipCall__Outputs(this);
  }
}

export class TransferOwnershipCall__Inputs {
  _call: TransferOwnershipCall;

  constructor(call: TransferOwnershipCall) {
    this._call = call;
  }

  get newOwner(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class TransferOwnershipCall__Outputs {
  _call: TransferOwnershipCall;

  constructor(call: TransferOwnershipCall) {
    this._call = call;
  }
}

export class UpdateAllowedTokensCall extends ethereum.Call {
  get inputs(): UpdateAllowedTokensCall__Inputs {
    return new UpdateAllowedTokensCall__Inputs(this);
  }

  get outputs(): UpdateAllowedTokensCall__Outputs {
    return new UpdateAllowedTokensCall__Outputs(this);
  }
}

export class UpdateAllowedTokensCall__Inputs {
  _call: UpdateAllowedTokensCall;

  constructor(call: UpdateAllowedTokensCall) {
    this._call = call;
  }

  get tokens(): Array<Address> {
    return this._call.inputValues[0].value.toAddressArray();
  }

  get statuses(): Array<boolean> {
    return this._call.inputValues[1].value.toBooleanArray();
  }
}

export class UpdateAllowedTokensCall__Outputs {
  _call: UpdateAllowedTokensCall;

  constructor(call: UpdateAllowedTokensCall) {
    this._call = call;
  }
}

export class UpdateBlackListedUserCall extends ethereum.Call {
  get inputs(): UpdateBlackListedUserCall__Inputs {
    return new UpdateBlackListedUserCall__Inputs(this);
  }

  get outputs(): UpdateBlackListedUserCall__Outputs {
    return new UpdateBlackListedUserCall__Outputs(this);
  }
}

export class UpdateBlackListedUserCall__Inputs {
  _call: UpdateBlackListedUserCall;

  constructor(call: UpdateBlackListedUserCall) {
    this._call = call;
  }

  get which(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get access(): boolean {
    return this._call.inputValues[1].value.toBoolean();
  }
}

export class UpdateBlackListedUserCall__Outputs {
  _call: UpdateBlackListedUserCall;

  constructor(call: UpdateBlackListedUserCall) {
    this._call = call;
  }
}

export class UpdateMinerFundsWalletCall extends ethereum.Call {
  get inputs(): UpdateMinerFundsWalletCall__Inputs {
    return new UpdateMinerFundsWalletCall__Inputs(this);
  }

  get outputs(): UpdateMinerFundsWalletCall__Outputs {
    return new UpdateMinerFundsWalletCall__Outputs(this);
  }
}

export class UpdateMinerFundsWalletCall__Inputs {
  _call: UpdateMinerFundsWalletCall;

  constructor(call: UpdateMinerFundsWalletCall) {
    this._call = call;
  }

  get newMinerFundsWallet(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class UpdateMinerFundsWalletCall__Outputs {
  _call: UpdateMinerFundsWalletCall;

  constructor(call: UpdateMinerFundsWalletCall) {
    this._call = call;
  }
}

export class UpdateMinerPriceAccretionPercentCall extends ethereum.Call {
  get inputs(): UpdateMinerPriceAccretionPercentCall__Inputs {
    return new UpdateMinerPriceAccretionPercentCall__Inputs(this);
  }

  get outputs(): UpdateMinerPriceAccretionPercentCall__Outputs {
    return new UpdateMinerPriceAccretionPercentCall__Outputs(this);
  }
}

export class UpdateMinerPriceAccretionPercentCall__Inputs {
  _call: UpdateMinerPriceAccretionPercentCall;

  constructor(call: UpdateMinerPriceAccretionPercentCall) {
    this._call = call;
  }

  get newPriceAccretionPercent(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }
}

export class UpdateMinerPriceAccretionPercentCall__Outputs {
  _call: UpdateMinerPriceAccretionPercentCall;

  constructor(call: UpdateMinerPriceAccretionPercentCall) {
    this._call = call;
  }
}

export class UpdateNodeFundsWalletCall extends ethereum.Call {
  get inputs(): UpdateNodeFundsWalletCall__Inputs {
    return new UpdateNodeFundsWalletCall__Inputs(this);
  }

  get outputs(): UpdateNodeFundsWalletCall__Outputs {
    return new UpdateNodeFundsWalletCall__Outputs(this);
  }
}

export class UpdateNodeFundsWalletCall__Inputs {
  _call: UpdateNodeFundsWalletCall;

  constructor(call: UpdateNodeFundsWalletCall) {
    this._call = call;
  }

  get newNodeFundsWallet(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class UpdateNodeFundsWalletCall__Outputs {
  _call: UpdateNodeFundsWalletCall;

  constructor(call: UpdateNodeFundsWalletCall) {
    this._call = call;
  }
}

export class UpdateNodeNftPriceCall extends ethereum.Call {
  get inputs(): UpdateNodeNftPriceCall__Inputs {
    return new UpdateNodeNftPriceCall__Inputs(this);
  }

  get outputs(): UpdateNodeNftPriceCall__Outputs {
    return new UpdateNodeNftPriceCall__Outputs(this);
  }
}

export class UpdateNodeNftPriceCall__Inputs {
  _call: UpdateNodeNftPriceCall;

  constructor(call: UpdateNodeNftPriceCall) {
    this._call = call;
  }

  get newPrice(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }
}

export class UpdateNodeNftPriceCall__Outputs {
  _call: UpdateNodeNftPriceCall;

  constructor(call: UpdateNodeNftPriceCall) {
    this._call = call;
  }
}

export class UpdateTokenRegistryCall extends ethereum.Call {
  get inputs(): UpdateTokenRegistryCall__Inputs {
    return new UpdateTokenRegistryCall__Inputs(this);
  }

  get outputs(): UpdateTokenRegistryCall__Outputs {
    return new UpdateTokenRegistryCall__Outputs(this);
  }
}

export class UpdateTokenRegistryCall__Inputs {
  _call: UpdateTokenRegistryCall;

  constructor(call: UpdateTokenRegistryCall) {
    this._call = call;
  }

  get newTokenRegistry(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class UpdateTokenRegistryCall__Outputs {
  _call: UpdateTokenRegistryCall;

  constructor(call: UpdateTokenRegistryCall) {
    this._call = call;
  }
}
