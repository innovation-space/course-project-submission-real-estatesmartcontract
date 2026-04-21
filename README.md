[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/XlSdAUjg)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=22674131&assignment_repo_type=AssignmentRepo)

# 🏠 Decentralized Real Estate Registry

> Polkadot Substrate (ink!) · GitHub Classroom Submission

## 📌 Overview
A completely decentralized, non-EVM real estate platform enabling trustless asset management. By leveraging the Polkadot Substrate ecosystem, this application eliminates traditional intermediaries, providing:
- Immutable property registration and ownership mapping
- Secure, trustless escrow-based purchase flows
- Automated, time-bound rental agreements
- On-chain dispute resolution and arbitration

## 🛠️ Tech Stack
- **Smart Contracts:** Rust (`ink!` framework)
- **Frontend UI:** Single Page Application (HTML/JS/CSS)
- **Wallet Integration:** Polkadot.js Browser Extension
- **Network:** Polkadot Substrate Node / Rococo Testnet

## 🌿 Branch Strategy
| Branch | Purpose |
|--------|---------|
| `main` | Production-ready codebase (UI + Rust backend) |
| `polkadot-migration` | Core architecture pivot and Rust `lib.rs` implementation |
| `feature-escrow` | Escrow logic and DOT token locking |
| `feature-ui-integration` | DOM rendering and Polkadot.js connectivity |

## 🚀 Project Milestones & Completion
- [x] Configure Substrate `Cargo.toml` build environment
- [x] Implement property registry state mapping in Rust
- [x] Build lightweight SPA UI for dynamic data rendering
- [x] Integrate Polkadot.js for secure wallet connectivity
- [x] Deploy escrow, rental, and dispute logic modules
- [x] Finalize presentation readiness and documentation
