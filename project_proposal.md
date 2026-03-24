# Project Proposal: Decentralized Real Estate Registry

## 1. Team Info
* **Team Name:** Innovation Space Team
* **Members:** * Bhumit Nagpal 23BKT0026
               * Mangal Singhal 23BKT0052
               *Ashwini Singh chouhan 23BKT0131 
  * [Add Partner Name or delete this line if solo]

## 2. Selected Blockchain Platform
**Polkadot (Substrate)**
* Per project constraints, we have actively excluded Ethereum/EVM. We selected the Polkadot Substrate ecosystem, specifically utilizing **Rust** and the **ink!** smart contract framework, due to its advanced cross-chain interoperability and low-latency transaction finality.

## 3. Use Case / Problem Statement
* **Problem:** Traditional real estate transactions are plagued by high intermediary fees, slow escrow processing, and opaque dispute resolution.
* **Solution:** We are building a fully decentralized, non-EVM platform that handles property registration, secure trustless escrow, automated rental agreements, and on-chain dispute arbitration.
* **Target Audience:** Property owners, prospective buyers, landlords, and tenants looking for a cryptographically secure, low-fee alternative to traditional real estate brokers.

## 4. High-Level Architecture
* **Frontend Dashboard:** A Single Page Application (SPA) built with vanilla HTML/JS/CSS for lightweight state management and rapid DOM rendering.
* **Wallet Integration:** Utilizing the Polkadot.js browser extension protocol for secure account authentication and transaction signing.
* **Smart Contracts (`ink!` / Rust):** * *Registry Module:* Maps Property IDs to Polkadot AccountIds.
  * *Escrow Module:* Time-locks DOT tokens (Plancks) pending transfer verifications.
  * *Rental/Dispute Modules:* Handles time-bound tenant agreements and flags centralized arbitration.
* **Network Integration:** Deployed to a local Substrate node / Rococo testnet for live block synchronization.

## 5. Timeline + Phases
* **Phase 1: UI & Architecture Setup (Week 1)**
  * Scaffold SPA interface and configure Substrate `Cargo.toml` environment.
  * *Assignee: Bhumit Nagpal*
* **Phase 2: Smart Contract Development (Week 2)**
  * Write and test `lib.rs` logic for registry, escrow, and rental modules.
  * *Assignee: Mangal Singhal*
* **Phase 3: Wallet Integration (Week 3)**
  * Integrate Polkadot.js mock API and UI state rendering.
  * *Assignee: Ashwini*
* **Phase 4: Final Testing & Demo Prep (Week 4)**
  * Code cleanup, documentation generation (`README.md`), and live presentation rehearsal.
  
