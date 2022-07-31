import { ethers } from "ethers";
import Alpine from 'alpinejs';

function web3AccountInit() {
  document.addEventListener('alpine:init', () => {
    Alpine.data('web3Account', () => ({
      isLogin: false,
      missingEthereum: false,
      network: { chainId: '', name: '' },
      account: { addr: '', balance: '0.00' },
      message: '',
      messageVerified: 0, // 1 -> Success, -1 -> Failed
      async login() {
        return this.init()
      },
      logout() {
        this.network.name = ''
        this.account.addr = ''
        this.account.balance = '0.00'
        this.isLogin = false
      },
      async init() {
        if (!window.ethereum) {
          this.missingEthereum = true
          return
        }

        window.ethereum.on('chainChanged', this.networkChanged.bind(this));
        window.ethereum.on('accountsChanged', this.accountsChanged.bind(this));

        this.missingEthereum = false

        try {
          const provider = new ethers.providers.Web3Provider(window.ethereum)

          this.network = await this.getNetwork(ethereum.chainId, provider)

          let addr = ethereum.selectedAddress
          if (!addr) {
            const accounts = await provider.send("eth_requestAccounts", []);
            addr = accounts[0]
          }

          await this.loadAccount(addr)
        } catch (e) {
          console.error(e)
        }
      },
      async loadAccount(addr) {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const balance = await provider.getBalance(addr)

        this.account = {
          addr,
          balance: ethers.utils.formatEther(balance)
        }

        this.isLogin = true
      },
      async getNetwork(chainId, provider) {
        // Not sure why chainId here is null, but provider.getNetwork can get correct one.
        let network = await provider.getNetwork(chainId)
        for (const n in NETWORKS) {
          if (NETWORKS[n].chainId === network.chainId) {
            return NETWORKS[n]
          }
        }
        return network
      },
      async networkChanged(chainId) {
        const provider = new ethers.providers.Web3Provider(window.ethereum)

        this.network = await this.getNetwork(chainId, provider)

        window.location.reload()
      },
      async accountsChanged(accounts) {
        if (accounts.length === 0) {
          return this.logout()
        }

        await this.loadAccount(accounts[0])
      },
      async signMessage(el) {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const signer = provider.getSigner()
        const signature = await signer.signMessage(this.message);

        el.dispatchEvent(new CustomEvent('send-signed-message', { detail: { msg: this.message, signature } }))
      },
      handleVerifiedResult(result) {
        if (result) {
          this.messageVerified = 1;
        } else {
          this.messageVerified = -1;
        }
        setTimeout(() => { this.messageVerified = 0 }, 2000)
      },
      async sendTransaction(addr, func, params) {
        console.log(addr, func, params)
        const data = get_data(func, params)
        console.log(data)

        const transactionParameters = {
          // nonce: '0x00', // ignored by MetaMask
          to: addr, // Required except during contract publications.
          from: ethereum.selectedAddress, // must match user's active address.
          // value: '0x00', // Only required to send ether to the recipient from the initiating external account.
          data: data, // Optional, but used for defining smart contract creation and interaction.
          // chainId: '0x3', // Used to prevent transaction reuse across blockchains. Auto-filled by MetaMask.
        };

        // txHash is a hex string
        // As with any RPC call, it may throw an error
        const txHash = await ethereum.request({
          method: 'eth_sendTransaction',
          params: [transactionParameters],
        });
        console.log(txHash)
      }
    }))
  })
}

function get_data(func, params) {
  const funcName = func.split("(")[0]
  const ABI = ["function "+func]
  const iface = new ethers.utils.Interface(ABI);
  const res = iface.encodeFunctionData(funcName, JSON.parse(params))
  return res
}

module.exports = {
  web3AccountInit
};
