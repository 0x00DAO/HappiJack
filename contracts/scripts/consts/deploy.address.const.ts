import { hardhatArguments } from 'hardhat';
import { deployNetwork } from './deploy.const';

type ContractDeployAddress = string | null;

interface ContractDeployAddressInterface {
  GameRoot?: ContractDeployAddress;
}
const ContractDeployAddress_Hardhat: ContractDeployAddressInterface = {};

const ContractDeployAddress_PolygonTestNet: ContractDeployAddressInterface = {
  GameRoot: '0xD6854CB80D600cD27FEC3f37f6AE560CADEA8244',
};

const ContractDeployAddress_PolygonMainNet: ContractDeployAddressInterface = {};

const ContractDeployAddress_EthTestNet: ContractDeployAddressInterface = {};

const ContractDeployAddress_EthMainNet: ContractDeployAddressInterface = {};

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
    default:
      _ContractDeployAddress = undefined as any;
      break;
  }
  return _ContractDeployAddress;
}

export const ContractDeployAddress: ContractDeployAddressInterface =
  getContractDeployAddress(hardhatArguments?.network) as any;
