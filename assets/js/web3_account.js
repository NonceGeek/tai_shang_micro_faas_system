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

          this.network = await provider.getNetwork(ethereum.chainId)

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
      async networkChanged(chainId) {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        this.network = await provider.getNetwork(chainId)
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
      }
    }))
  })
}

module.exports = {
  web3AccountInit
};
