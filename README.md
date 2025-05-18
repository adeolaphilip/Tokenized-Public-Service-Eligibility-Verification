# Tokenized Public Service Eligibility Verification System

A blockchain-based system for managing public service eligibility verification using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a secure, transparent, and efficient way to manage citizen identity, eligibility criteria, document verification, benefit allocation, and audit trails for public services.

## Smart Contracts

The system consists of five main smart contracts:

### 1. Citizen Identity Contract

Manages resident information and identity verification.

- Register and verify citizens
- Manage authorized verifiers
- Query citizen information and verification status

### 2. Eligibility Criteria Contract

Records service requirements and eligibility rules.

- Define service types and their eligibility criteria
- Specify required documentation for each service
- Query service and eligibility information

### 3. Documentation Verification Contract

Validates supporting materials for service eligibility.

- Submit documents for verification
- Verify submitted documents
- Query document submission status

### 4. Benefit Allocation Contract

Manages service distribution and benefit allocation.

- Allocate benefits to eligible citizens
- Process benefit claims
- Track benefit status and history

### 5. Audit Trail Contract

Records benefit provision history and system events.

- Record all system events
- Provide transparent audit trail
- Control access to audit information

## Key Features

- **Secure Identity Management**: Citizen identities are securely stored and verified by authorized verifiers
- **Transparent Eligibility Rules**: Service eligibility criteria are clearly defined and publicly accessible
- **Document Verification**: Secure verification of supporting documents with cryptographic hashing
- **Benefit Allocation**: Structured allocation and claiming of benefits with proper authorization
- **Comprehensive Audit Trail**: All system events are recorded for transparency and accountability
- **Role-Based Access Control**: Different roles (verifiers, administrators, auditors) with specific permissions

## System Architecture

\`\`\`
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Citizen        │     │  Eligibility    │     │  Documentation  │
│  Identity       │────>│  Criteria       │────>│  Verification   │
│  Contract       │     │  Contract       │     │  Contract       │
└─────────────────┘     └─────────────────┘     └─────────────────┘
│
▼
┌─────────────────┐                         ┌─────────────────┐
│  Audit Trail    │<────────────────────────│  Benefit        │
│  Contract       │                         │  Allocation     │
└─────────────────┘                         │  Contract       │
└─────────────────┘
\`\`\`

## Testing

Run the tests using Vitest:

\`\`\`bash
npm test
\`\`\`

## Development

### Prerequisites

- Node.js and npm
- Clarity language knowledge
- Basic understanding of blockchain concepts

### Setup

1. Clone the repository
2. Install dependencies: `npm install`
3. Run tests: `npm test`

## Usage Flow

1. Register citizens in the Citizen Identity Contract
2. Define service types and eligibility criteria
3. Citizens submit documentation for verification
4. Verify submitted documents
5. Allocate benefits to eligible citizens
6. Citizens claim benefits
7. Process benefit claims
8. All actions are recorded in the audit trail

## Security Considerations

- All contract functions implement proper authorization checks
- Critical operations require specific roles
- Audit trail ensures transparency and accountability
- Document hashing provides integrity verification

## License

MIT
\`\`\`

```mermaid title="System Architecture" type="diagram"
graph TD;
    A["Citizen Identity Contract"]-->B["Eligibility Criteria Contract"]
    B-->C["Documentation Verification Contract"]
    C-->D["Benefit Allocation Contract"]
    D-->E["Audit Trail Contract"]
    A-.->E
    B-.->E
    C-.->E
