# Nelo Buy Contracts

This repository holds the contracts used to buy the NELO token through the app.

Supports a three level referral system.

## Compile token contract

```shell
npx hardhat compile
```

## Deploy token contract

```shell
npx hardhat run --network bsc scripts/deploy.js
```

## Verify contract

```shell
npx hardhat verify "<contract-address>" --network bsc
```