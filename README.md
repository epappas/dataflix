# 🏗 Dataflix

Dataflix is a platform that allows users to freely share data in web3. The goal of Dataflix is to create a decentralized
and transparent data sharing ecosystem that empowers users to control their own data and monetize it on their terms.

## Quick Start

Prerequisites:

- Node (v16 LTS)](https://nodejs.org/en/download/)
- [Yarn (v1.x)](https://classic.yarnpkg.com/en/docs/install/)
- You need an RPC key for testnets and production deployments, create an [Alchemy](https://www.alchemy.com/) account and
  replace the value of `ALCHEMY_KEY = xxx` in `packages/react-app/src/constants.js` with your new key.
- Make sure you update the `InfuraID` before you go to production.

> clone/fork 🏗 dataflix:

```bash
git clone https://github.com/epappas/dataflix.git
```

> install and start your 👷‍ Hardhat chain:

```bash
cd dataflix
yarn install
yarn chain
```

> in a second terminal window, start your 📱 frontend:

```bash
cd dataflix
yarn start
```

> in a third terminal window, 🛰 deploy your contract:

```bash
cd dataflix
yarn deploy
```

Open `http://localhost:3000` to see the app

## Contribution Guidelines

We welcome contributions to Dataflix! If you would like to contribute, please follow these guidelines:

Fork the repository and create a new branch for your changes. Make your changes and test them thoroughly. Follow the
repository's code style and formatting guidelines. Open a pull request and describe your changes clearly. Thank you for
considering contributing to Dataflix!
