# CyberDuel 🛡️⚔️

A futuristic digital combat arena where hackers deploy encrypted cyber weapons in strategic battles on the blockchain.

## Overview

CyberDuel is a decentralized game built on the Stacks blockchain that combines the classic rock-paper-scissors mechanics with a cybersecurity theme. Two hackers engage in encrypted battles, deploying cyber weapons against each other in a secure, trustless environment.

## Game Mechanics

### Cyber Weapons

The game features three primary cyber weapons, each with strategic advantages:

- **🦠 Virus** - Infiltrates and defeats Firewall systems
- **🛡️ Firewall** - Blocks and defeats DDoS attacks  
- **💥 DDoS Attack** - Overwhelms and defeats Virus programs

### Battle Flow

1. **Session Initialization**: A hacker creates a battle session and invites an opponent
2. **Weapon Deployment**: Both hackers submit encrypted weapon choices
3. **Decryption Phase**: Once both weapons are deployed, hackers reveal their choices
4. **Battle Resolution**: The smart contract determines the winner based on weapon effectiveness

### Encryption System

CyberDuel uses a commit-reveal scheme to ensure fair play:
- Hackers first submit encrypted weapon choices (SHA256 hash)
- The hash includes: weapon type + encryption key + player address
- After both players commit, they reveal their actual weapons to determine the winner

## Smart Contract Functions

### Public Functions

- `init-hack-battle(target-hacker, server-target)` - Start a new battle session
- `deploy-weapon(session-id, encrypted-payload)` - Submit encrypted weapon choice
- `decrypt-weapon(session-id, weapon, encryption-key)` - Reveal weapon and resolve battle

### Read-Only Functions

- `get-battle-status(session-id)` - View complete battle information
- `get-battle-winner(session-id)` - Check battle outcome
- `weapon-name(weapon-code)` - Get human-readable weapon names
- `get-server-target(session-id)` - View target server IP

## Battle States

- **Deploying Weapons** (0) - Waiting for encrypted weapon submissions
- **Decrypting Code** (1) - Both weapons deployed, awaiting reveals
- **Battle Complete** (2) - Winner determined, battle finished

## Error Codes

- `ERR-ACCESS-DENIED` (100) - Cannot battle yourself
- `ERR-SESSION-NOT-FOUND` (101) - Invalid session ID
- `ERR-ALREADY-DEPLOYED` (102) - Weapon already submitted
- `ERR-NOT-DEPLOYED` (103) - Weapon not yet deployed
- `ERR-ALREADY-DECRYPTED` (104) - Weapon already revealed
- `ERR-INVALID-WEAPON` (105) - Invalid weapon type or hash
- `ERR-BATTLE-TERMINATED` (106) - Battle in wrong state
- `ERR-DECRYPT-TOO-EARLY` (107) - Cannot decrypt before deployment phase
- `ERR-UNAUTHORIZED-HACKER` (108) - Not a participant in this battle

## Getting Started

### Prerequisites

- Stacks wallet (Hiro Wallet recommended)
- STX tokens for transaction fees
- Understanding of blockchain transactions

### Deployment

1. Deploy the smart contract to Stacks blockchain
2. Note the contract address for interaction
3. Use a Stacks-compatible frontend or CLI tools to interact

### Playing a Game

1. Call `init-hack-battle` with opponent's address and target server
2. Both players call `deploy-weapon` with encrypted weapon choices
3. Both players call `decrypt-weapon` to reveal choices and determine winner

## Example Usage

```clarity
;; Start a battle
(contract-call? .cyberduel init-hack-battle 'SP2...OPPONENT "192.168.1.100")

;; Deploy encrypted virus (weapon=1, key=12345)
(contract-call? .cyberduel deploy-weapon u1 (sha256 "encrypted-payload"))

;; Reveal weapon choice
(contract-call? .cyberduel decrypt-weapon u1 u1 u12345)
```

## Security Features

- **Commit-Reveal Scheme**: Prevents front-running and ensures fair gameplay
- **State Management**: Enforces proper game flow and prevents invalid moves
- **Access Control**: Only battle participants can make moves
- **Deterministic Resolution**: Transparent winner determination

## Future Enhancements

- Multiple weapon types and special abilities
- Tournament brackets and leaderboards  
- NFT rewards for winners
- Advanced encryption schemes
- Spectator mode and battle replays

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

---

*Enter the digital battlefield. Deploy your weapons. May the best hacker win.* 🚀