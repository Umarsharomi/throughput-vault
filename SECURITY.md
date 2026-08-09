# Security

## Static analysis

Slither was run against `src/ThroughputVault.sol` with dependency findings excluded.

The only initial finding was `pragma`, an informational warning caused by
different Solidity pragmas in OpenZeppelin dependencies. No High, Medium, or
Low severity findings were reported in the production contract.

Command:

```bash
slither src/ThroughputVault.sol --exclude-dependencies --exclude pragma
