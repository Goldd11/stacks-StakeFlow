# Community DAO Contract - README

This contract is designed for a decentralized autonomous organization (DAO) dedicated to local community development. The DAO facilitates project proposals, voting, and fund management. It is structured to empower members with governance rights, allow them to submit and vote on proposals, manage the DAO treasury, and interact with the DAO's reputation system.

This README provides an overview of the contract's functions, their purpose, how to use them, and the underlying logic.

---

## Contract Overview

The **Community DAO Contract** enables the following key functionalities:

1. **Proposal Management** – Members can submit project proposals for funding, vote on proposals, and execute successful proposals.
2. **Voting System** – Members can cast votes on proposals and delegate votes to others.
3. **Fund Management** – Members can fund the DAO, execute proposals that require treasury funds, and withdraw funds from the DAO treasury.
4. **Membership & Reputation Management** – Members can join the DAO, increase their reputation, and transfer reputation between members.
5. **Security Features** – Strict authorization checks ensure that only authorized DAO members can perform specific actions.

---

## Key Components and Data Structures

### Constants
- **VOTING_PERIOD**: The duration (in blocks) for which voting on proposals remains open (set to ~10 days).
- **MIN_PROPOSAL_AMOUNT**: The minimum amount of funds (in microSTX) required to submit a proposal.
- **REQUIRED_APPROVAL_PERCENTAGE**: The percentage of total votes required for a proposal to be approved (set to 70%).

### Data Maps
- **proposals**: A map holding information about all the proposals in the DAO. Each proposal is identified by a unique `proposal-id`.
- **votes**: A map storing voting information for each voter-proposal pair.
- **member-details**: A map storing member-specific information, including reputation.

### Variables
- **proposal-count**: A counter for generating unique `proposal-id`s.
- **dao-treasury**: The balance of funds held in the DAO treasury.

### Error Codes
The contract defines the following error codes for various checks:
- `ERR-NOT-AUTHORIZED`: Unauthorized action (e.g., non-member attempting to interact).
- `ERR-INVALID-PROPOSAL`: Invalid proposal (e.g., proposal does not exist or has expired).
- `ERR-ALREADY-VOTED`: The member has already voted on this proposal.
- `ERR-PROPOSAL-EXPIRED`: The proposal’s voting period has ended.
- `ERR-INSUFFICIENT-FUNDS`: Insufficient funds for a proposal or withdrawal.
- `ERR-ZERO-AMOUNT`: Zero amount error, often when an action requires a non-zero amount.
- `ERR-INVALID-STATUS`: Invalid status (e.g., non-active proposals).
- `ERR-SELF-DELEGATION`: A member cannot delegate a vote to themselves.
- `ERR-INVALID-TITLE-LENGTH` and `ERR-INVALID-DESC-LENGTH`: Title and description lengths are invalid (must be non-zero).

---

## Functions

### 1. **Proposal Management**

#### `submit-proposal`
- **Purpose**: Allows a DAO member to submit a proposal for funding.
- **Parameters**:
  - `title`: The title of the proposal (max length: 256 characters).
  - `description`: A detailed description of the proposal (max length: 1024 characters).
  - `amount`: The amount of funds requested (must be at least `MIN_PROPOSAL_AMOUNT`).
- **Logic**:
  - The sender must be a DAO member.
  - The title and description must not be empty.
  - The amount requested must be greater than zero and meet the minimum proposal amount requirement.
  - Proposals are active for a period defined by `VOTING_PERIOD`.

**Usage Example**:
```clojure
(submit-proposal title="Community Park" description="Build a new park" amount=5000000)
```

---

### 2. **Voting System**

#### `cast-vote`
- **Purpose**: Allows a DAO member to vote on a proposal.
- **Parameters**:
  - `proposal-id`: The ID of the proposal to vote on.
  - `vote-for`: A boolean indicating whether the vote is in favor (true) or against (false) the proposal.
- **Logic**:
  - Only authorized DAO members can vote.
  - A member can only vote once on each proposal.
  - Votes can only be cast while the proposal is still active (within the `VOTING_PERIOD`).
  - The contract tracks votes as "for" or "against" a proposal.

**Usage Example**:
```clojure
(cast-vote proposal-id=123 vote-for=true)
```

---

### 3. **Fund Management**

#### `fund-dao`
- **Purpose**: Allows a DAO member to fund the DAO treasury.
- **Logic**:
  - The sender can transfer STX to the DAO contract, which adds the amount to the `dao-treasury`.

**Usage Example**:
```clojure
(fund-dao)
```

#### `execute-proposal`
- **Purpose**: Executes an approved proposal and transfers funds to the proposer.
- **Parameters**:
  - `proposal-id`: The ID of the proposal to execute.
- **Logic**:
  - The proposal must have passed the voting stage.
  - The DAO must have enough funds to fulfill the proposal's request.
  - Once executed, the proposal's status is set to "done" and funds are transferred to the proposer.

**Usage Example**:
```clojure
(execute-proposal proposal-id=123)
```

---

### 4. **Membership & Reputation Management**

#### `join-dao`
- **Purpose**: Allows a new member to join the DAO by staking a minimum amount of funds.
- **Parameters**:
  - `stake`: The amount of STX to stake for joining the DAO.
- **Logic**:
  - The sender must stake at least `MIN_PROPOSAL_AMOUNT`.
  - The staked amount is transferred to the DAO treasury and the sender's reputation is increased.

**Usage Example**:
```clojure
(join-dao stake=1000000)
```

#### `delegate-vote`
- **Purpose**: Allows a member to delegate their vote to another member on a specific proposal.
- **Parameters**:
  - `delegate-to`: The member to whom the vote is delegated.
  - `proposal-id`: The ID of the proposal.
- **Logic**:
  - The delegating member must not have already voted.
  - Delegation to oneself is not allowed.
  - The proposal must still be active.

**Usage Example**:
```clojure
(delegate-vote delegate-to=<member-principal> proposal-id=123)
```

#### `increase-reputation`
- **Purpose**: Increases the reputation of another DAO member.
- **Parameters**:
  - `member`: The member whose reputation is being increased.
- **Logic**:
  - Only authorized DAO members can increase others' reputation.

**Usage Example**:
```clojure
(increase-reputation member=<member-principal>)
```

---

### 5. **Read-Only Functions**

#### `get-proposal`
- **Purpose**: Retrieves the details of a proposal by its `proposal-id`.
- **Parameters**:
  - `proposal-id`: The ID of the proposal.

**Usage Example**:
```clojure
(get-proposal proposal-id=123)
```

#### `get-treasury-balance`
- **Purpose**: Retrieves the current balance of the DAO treasury.

**Usage Example**:
```clojure
(get-treasury-balance)
```

#### `get-member-reputation`
- **Purpose**: Retrieves the reputation of a specific DAO member.
- **Parameters**:
  - `member`: The member whose reputation is being queried.

**Usage Example**:
```clojure
(get-member-reputation member=<member-principal>)
```

---

### 6. **Additional Functions**

#### `withdraw-stake`
- **Purpose**: Allows a DAO member to withdraw a portion of their stake from the DAO treasury.
- **Parameters**:
  - `amount`: The amount of funds to withdraw.
- **Logic**:
  - The sender must have sufficient funds in the DAO treasury.

**Usage Example**:
```clojure
(withdraw-stake amount=500000)
```

#### `cancel-proposal`
- **Purpose**: Allows a proposer to cancel their proposal.
- **Parameters**:
  - `proposal-id`: The ID of the proposal to cancel.
- **Logic**:
  - Only the proposer can cancel the proposal.

**Usage Example**:
```clojure
(cancel-proposal proposal-id=123)
```

#### `transfer-reputation`
- **Purpose**: Allows a DAO member to transfer reputation to another member.
- **Parameters**:
  - `to`: The recipient member.
  - `amount`: The amount of reputation to transfer.
- **Logic**:
  - The sender must have enough reputation to transfer.

**Usage Example**:
```clojure
(transfer-reputation to=<member-principal> amount=5)
```

---
