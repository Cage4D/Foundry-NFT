# Foundry NFT

Cyfrin Updraft NFT course project. Two ERC721 contracts:

- **BasicNft** (`src/BasicNft.sol`): mints a token that points at an IPFS metadata URI (the pug).
- **MoodNft** (`src/MoodNft.sol`): fully on-chain NFT. The metadata JSON and the SVG image are both base64-encoded data URIs. The owner (or an approved address) can flip the mood between happy and sad.

## Usage

```shell
forge build
forge test
```

### Local deploy (Anvil)

In one terminal: `make anvil`. In another:

```shell
make deploy        # BasicNft
make mint          # mint a pug on the latest BasicNft
make deployMood    # MoodNft (reads img/happy.svg and img/sad.svg)
make mintMoodNft   # mint a MoodNft
make flipMoodNft   # flip token 0's mood
```

### Sepolia

Create a `.env` with `SEPOLIA_RPC_URL`, `ETHERSCAN_API_KEY` and `ACCOUNT` (a `cast wallet` keystore name), then:

```shell
make deployMood ARGS="--network sepolia"
```

## Note on the base64 test

`svgToImageURI` base64-encodes the SVG's exact bytes. Newlines, indentation and double spaces all change the output, so the test reads `img/happy.svg` from disk instead of using a hand-copied string.
