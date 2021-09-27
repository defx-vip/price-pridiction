import { ChainId, Token, WETH, Fetcher, Route } from "@pancakeswap-libs/sdk-v2";
import { ethers } from "ethers";
const provider = new ethers.providers.Web3Provider(window.ethereum)
const BUSD = new Token(
  ChainId.BSCTESTNET,
  "0x78867bbeef44f2326bf8ddd1941a4439382ef2a7",
  18
);

const WBNB = new Token(
  ChainId.BSCTESTNET,
    "0xae13d989dac2f0debff460ac112a837c89baa7cd",
    18
  );

// note that you may want/need to handle this async code differently,
// for example if top-level await is not an option
console.info( provider)
const pair = await Fetcher.fetchPairData(BUSD, WBNB, provider);

const route = new Route([pair], WBNB);

console.log(route.midPrice.toSignificant(6)); // 201.306
console.log(route.midPrice.invert().toSignificant(6)); // 0.00496756

