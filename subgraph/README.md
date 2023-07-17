# How to Build a Subgraph for a Smart Contract

## add smart contract to subgraph

1. query smart contract address from system
2. add new contract abi to abis folder
3. add smart contract address to subgraph.yaml

```yaml
./node_modules/.bin/graph add 0xbF27cba0534796004493D1b9309bCbD49C6A0D15 --abi ../abis/LotteryGame
LotteryResultVerifySystem.json --contract-name LotteryGameLotteryResultVerifySystem
```

4. generate subgraph.yaml

```yaml
npm run codegen
```

5. generate assembly script

```yaml
npm run build
```

6. deploy subgraph

```yaml
npm run deploy
```
