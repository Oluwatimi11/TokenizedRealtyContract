# Real Estate Asset Tokenization Smart Contract

A Clarity smart contract for tokenizing real estate assets on the Stacks blockchain, implementing the SIP-010 fungible token standard.

## Overview

This smart contract enables the tokenization of real estate properties, allowing for fractional ownership through digital shares. It provides functionality for property registration, share issuance, transfers, and property valuation updates while maintaining compliance with regulatory requirements through proper access controls.

## Features

- **SIP-010 Compliance**: Implements the standard fungible token interface
- **Property Registration**: Detailed property information storage including location, type, and metrics
- **Share Management**: Issue and transfer property shares between investors
- **Valuation Updates**: Maintain current property valuations and key metrics
- **Access Controls**: Developer-only administrative functions
- **Property Metrics**: Calculate key real estate metrics like market cap and yield

## Core Functions

### Administrative Functions

```clarity
register-property: Register a new property with detailed information
issue-property-shares: Issue new shares to investors
update-property-valuation: Update property metrics and valuations
set-property-documents: Set legal documentation references
```

### Investor Functions

```clarity
transfer-shares: Transfer shares between investors
get-investor-shares: Check share balance for any investor
```

### Read-Only Functions

```clarity
get-property-details: Retrieve complete property information
get-property-metrics: Calculate and return key property metrics
get-property-documents: Access legal documentation references
get-total-shares: View total shares issued
```

## Data Structures

### Property Registry
Stores comprehensive property information including:
- Street address
- Property type (residential, commercial, industrial)
- Total area in square feet
- Share price in USD
- Total shares
- Construction year
- Last valuation date
- Rental income (annual)
- Occupancy rate
- Maintenance reserve

### Share Management
- Tracks individual investor share balances
- Maintains total shares issued
- Records authorized brokers

## Error Codes

- `err-unauthorized-developer (u100)`: Unauthorized developer action
- `err-unauthorized-owner (u101)`: Unauthorized share transfer
- `err-insufficient-shares (u102)`: Insufficient shares for transfer
- `err-property-not-found (u103)`: Property not found in registry
- `err-invalid-valuation (u104)`: Invalid property valuation

## Property Metrics Calculation

The contract automatically calculates:
- Market capitalization
- Annual yield percentage
- Price per square foot

## Usage Examples

### Registering a Property
```clarity
(contract-call? .real-estate-token register-property 
    u1                           ;; deed-id
    "123 Main St"               ;; street-address
    "residential"               ;; property-type
    u2000                       ;; total-area-sqft
    u100000                     ;; share-price-usd
    u1000                       ;; total-shares
    u2020                       ;; construction-year
    u50000                      ;; rental-income-annual
    u95                         ;; occupancy-rate
    u10000                      ;; maintenance-reserve
)
```

### Transferring Shares
```clarity
(contract-call? .real-estate-token transfer-shares
    u100                        ;; share-amount
    tx-sender                   ;; current-owner
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; new-owner
    none                        ;; transfer-memo
)
```

## Security Considerations

- Only the designated property developer can perform administrative functions
- Share transfers require sufficient balance verification
- Property valuations must be greater than zero
- All sensitive operations include appropriate access controls

## Dependencies

- Requires implementation of SIP-010 trait
- Designed for Stacks blockchain
- Uses Clarity language version compatible with Stacks 2.0 and above

## License