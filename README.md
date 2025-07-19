# Digital Patent Licensing Marketplace

A comprehensive blockchain-based system for managing patent portfolios, facilitating licensing negotiations, calculating royalties, monitoring infringement, and verifying prior art.

## System Overview

The Digital Patent Licensing Marketplace consists of five interconnected smart contracts that work together to create a complete patent management ecosystem:

### 1. Patent Portfolio Management Contract (`patent-portfolio.clar`)
- Registers and manages patent assets
- Tracks patent ownership and metadata
- Handles patent transfers and updates
- Maintains patent status and expiration dates

### 2. Licensing Negotiation Contract (`licensing-negotiation.clar`)
- Facilitates licensing agreement negotiations
- Manages licensing proposals and counteroffers
- Handles agreement acceptance and rejection
- Tracks licensing terms and conditions

### 3. Royalty Calculation Contract (`royalty-calculation.clar`)
- Calculates royalty payments based on usage
- Manages different royalty structures
- Handles payment distributions
- Tracks royalty payment history

### 4. Infringement Monitoring Contract (`infringement-monitoring.clar`)
- Reports and tracks patent infringement cases
- Manages infringement dispute resolution
- Handles evidence submission
- Tracks infringement penalties

### 5. Prior Art Verification Contract (`prior-art-verification.clar`)
- Validates patent novelty claims
- Manages prior art submissions
- Handles verification processes
- Tracks verification results

## Key Features

- **Decentralized Patent Management**: Complete on-chain patent portfolio tracking
- **Automated Licensing**: Streamlined licensing negotiation process
- **Fair Royalty Distribution**: Transparent royalty calculation and payment
- **Infringement Protection**: Comprehensive monitoring and dispute resolution
- **Prior Art Validation**: Rigorous novelty verification system

## Technical Architecture

### Data Structures
- Patents stored with comprehensive metadata
- Licensing agreements with flexible terms
- Royalty structures supporting multiple models
- Infringement cases with evidence tracking
- Prior art records with verification status

### Security Features
- Owner-only modifications for sensitive operations
- Multi-step verification processes
- Immutable audit trails
- Access control mechanisms

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Basic understanding of Clarity smart contracts

### Installation

\`\`\`bash
git clone <repository-url>
cd digital-patent-licensing-marketplace
npm install
\`\`\`

### Testing

\`\`\`bash
npm test
\`\`\`

### Deployment

\`\`\`bash
clarinet deploy
\`\`\`

## Contract Interactions

### Patent Registration
1. Call `register-patent` with patent details
2. System assigns unique patent ID
3. Patent becomes available for licensing

### Licensing Process
1. Submit licensing proposal
2. Patent owner reviews and responds
3. Agreement finalized on acceptance
4. Royalty payments begin

### Royalty Management
1. Usage reported to royalty contract
2. Payments calculated automatically
3. Distributions made to patent owners

### Infringement Handling
1. Infringement reported with evidence
2. Dispute resolution process initiated
3. Penalties applied if confirmed

### Prior Art Verification
1. Prior art submitted for review
2. Verification process conducted
3. Results recorded on-chain

## Error Codes

- `ERR-NOT-AUTHORIZED (u100)`: Caller lacks required permissions
- `ERR-PATENT-NOT-FOUND (u101)`: Referenced patent does not exist
- `ERR-INVALID-INPUT (u102)`: Invalid input parameters
- `ERR-ALREADY-EXISTS (u103)`: Resource already exists
- `ERR-EXPIRED (u104)`: Patent or agreement has expired
- `ERR-INSUFFICIENT-FUNDS (u105)`: Insufficient payment amount

## License

This project is licensed under the MIT License.
