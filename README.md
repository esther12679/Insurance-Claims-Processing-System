# Insurance Claims Processing System

A decentralized insurance claims processing system built on Stacks blockchain using Clarity smart contracts.

## System Overview

This system automates the entire insurance claims lifecycle through five interconnected smart contracts:

1. **Policy Verification Contract** - Validates coverage terms and conditions
2. **Claim Submission Contract** - Records loss reports and supporting evidence
3. **Damage Assessment Contract** - Evaluates claim validity and compensation
4. **Fraud Detection Contract** - Identifies suspicious claim patterns
5. **Settlement Payment Contract** - Automates approved claim disbursements

## Architecture

The system follows a modular approach where each contract handles a specific aspect of claims processing:

\`\`\`
Policy Verification → Claim Submission → Damage Assessment → Fraud Detection → Settlement Payment
\`\`\`

## Key Features

- **Automated Policy Validation**: Verifies active coverage and policy terms
- **Tamper-Proof Claims**: Immutable record of all claim submissions
- **AI-Assisted Assessment**: Algorithmic damage evaluation and compensation calculation
- **Fraud Prevention**: Pattern recognition to identify suspicious activities
- **Instant Settlements**: Automated payments for approved claims

## Data Structures

### Policy
- Policy ID (uint)
- Policy holder (principal)
- Coverage amount (uint)
- Premium paid (uint)
- Expiry date (uint)
- Status (active/inactive)

### Claim
- Claim ID (uint)
- Policy ID (uint)
- Claimant (principal)
- Incident date (uint)
- Claim amount (uint)
- Evidence hash (buff)
- Status (submitted/assessed/approved/rejected/paid)

### Assessment
- Assessment ID (uint)
- Claim ID (uint)
- Assessor (principal)
- Damage score (uint)
- Recommended amount (uint)
- Assessment date (uint)

## Getting Started

### Prerequisites
- Clarinet CLI
- Node.js 18+
- Vitest for testing

### Installation

\`\`\`bash
git clone <repository-url>
cd insurance-claims-processing
npm install
\`\`\`

### Running Tests

\`\`\`bash
npm test
\`\`\`

### Deployment

\`\`\`bash
clarinet deployments generate --devnet
clarinet deployments apply --devnet
\`\`\`

## Contract Interactions

### 1. Register Policy
\`\`\`clarity
(contract-call? .policy-verification register-policy coverage-amount premium expiry-date)
\`\`\`

### 2. Submit Claim
\`\`\`clarity
(contract-call? .claim-submission submit-claim policy-id incident-date claim-amount evidence-hash)
\`\`\`

### 3. Assess Damage
\`\`\`clarity
(contract-call? .damage-assessment assess-claim claim-id damage-score recommended-amount)
\`\`\`

### 4. Check Fraud
\`\`\`clarity
(contract-call? .fraud-detection analyze-claim claim-id)
\`\`\`

### 5. Process Payment
\`\`\`clarity
(contract-call? .settlement-payment process-settlement claim-id)
\`\`\`

## Error Codes

- ERR-NOT-AUTHORIZED (u100)
- ERR-POLICY-NOT-FOUND (u101)
- ERR-POLICY-EXPIRED (u102)
- ERR-CLAIM-NOT-FOUND (u103)
- ERR-INVALID-AMOUNT (u104)
- ERR-FRAUD-DETECTED (u105)
- ERR-INSUFFICIENT-BALANCE (u106)
- ERR-ALREADY-PROCESSED (u107)

## Security Considerations

- All contracts use proper authorization checks
- Fraud detection algorithms prevent duplicate claims
- Multi-signature requirements for large settlements
- Time-locked payments for dispute resolution

## Contributing

Please read the PR-DETAILS.md file for contribution guidelines and development workflow.
