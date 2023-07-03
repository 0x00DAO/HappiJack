import { hardhatArguments } from 'hardhat';
import { deployNetwork } from './deploy.const';

type ContractDeployAddress = string | null;

interface ContractDeployAddressInterface {
  GameRoot?: ContractDeployAddress;
}
const ContractDeployAddress_Hardhat: ContractDeployAddressInterface = {};

const ContractDeployAddress_PolygonTestNet: ContractDeployAddressInterface = {
  GameRoot: '0xa652FcC9ee53b0A85414d0c5f4F041e2D556409E',
};

const ContractDeployAddress_PolygonMainNet: ContractDeployAddressInterface = {};

const ContractDeployAddress_EthTestNet: ContractDeployAddressInterface = {};

const ContractDeployAddress_EthMainNet: ContractDeployAddressInterface = {};

const ContractDeployAddress_BscTestNet: ContractDeployAddressInterface = {};

const ContractDeployAddress_BscMainNet: ContractDeployAddressInterface = {};

const ContractDeployAddress_ArbitrumTestNet: ContractDeployAddressInterface = {
  GameRoot: '0xD6854CB80D600cD27FEC3f37f6AE560CADEA8244',
};

const ContractDeployAddress_ArbitrumMainNet: ContractDeployAddressInterface =
  {};

const ContractDeployAddress_ZkSyncEraTestNet: ContractDeployAddressInterface = {
  GameRoot: null,
};

const ContractDeployAddress_ZkSyncEraMainNet: ContractDeployAddressInterface =
  {};

const ContractDeployAddress_PolygonZkEvmTestNet: ContractDeployAddressInterface =
  {};

const ContractDeployAddress_PolygonZkEvmMainNet: ContractDeployAddressInterface =
  {};

export function getContractDeployAddress(
  network?: string
): ContractDeployAddressInterface {
  let _ContractDeployAddress: ContractDeployAddressInterface = null as any;

  switch (network) {
    case deployNetwork.hardhat:
      _ContractDeployAddress = ContractDeployAddress_Hardhat;
      break;
    case deployNetwork.polygon_testnet:
      _ContractDeployAddress = ContractDeployAddress_PolygonTestNet;
      break;
    case deployNetwork.polygon_mainnet:
      _ContractDeployAddress = ContractDeployAddress_PolygonMainNet;
      break;
    case deployNetwork.eth_testnet:
      _ContractDeployAddress = ContractDeployAddress_EthTestNet;
      break;
    case deployNetwork.eth_mainnet:
      _ContractDeployAddress = ContractDeployAddress_EthMainNet;
      break;
    case deployNetwork.bsc_testnet:
      _ContractDeployAddress = ContractDeployAddress_BscTestNet;
      break;
    case deployNetwork.bsc_mainnet:
      _ContractDeployAddress = ContractDeployAddress_BscMainNet;
      break;
    case deployNetwork.arbitrum_testnet:
      _ContractDeployAddress = ContractDeployAddress_ArbitrumTestNet;
      break;
    case deployNetwork.arbitrum_mainnet:
      _ContractDeployAddress = ContractDeployAddress_ArbitrumMainNet;
      break;

    case deployNetwork.zksync_era_testnet:
      _ContractDeployAddress = ContractDeployAddress_ZkSyncEraTestNet;
      break;
    case deployNetwork.zksync_era_mainnet:
      _ContractDeployAddress = ContractDeployAddress_ZkSyncEraMainNet;
      break;
    case deployNetwork.polygon_zkevm_testnet:
      _ContractDeployAddress = ContractDeployAddress_PolygonZkEvmTestNet;
      break;
    case deployNetwork.polygon_zkevm_mainnet:
      _ContractDeployAddress = ContractDeployAddress_PolygonZkEvmMainNet;
      break;

    default:
      _ContractDeployAddress = undefined as any;
      break;
  }
  return _ContractDeployAddress;
}

export const ContractDeployAddress: ContractDeployAddressInterface =
  getContractDeployAddress(hardhatArguments?.network) as any;
