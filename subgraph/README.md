# How to Build a Subgraph for a Smart Contract

## init subgraph

```bash
./node_modules/.bin/graph init --product subgraph-studio --from-contract 0xc3888b3EEF69B6e017bcC5c0Abfbe7D11e418301 --network arbitrum-one --abi ./abis/LotteryGameSystem.json happiairdrop-arb
```

## add smart contract to subgraph

1. query smart contract address from system
2. add new contract abi to abis folder
3. add smart contract address to subgraph.yaml

```bash
./node_modules/.bin/graph add 0xbF27cba0534796004493D1b9309bCbD49C6A0D15 --abi ../abis/LotteryGame
LotteryResultVerifySystem.json --contract-name LotteryGameLotteryResultVerifySystem
```

4. generate subgraph.yaml

```bash
npm run codegen
```

5. generate assembly script

```bash
npm run build
```

6. deploy subgraph

```bash
npm run deploy
```
