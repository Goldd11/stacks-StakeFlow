;; Community DAO Contract
;; Handles project proposals, voting, and fund management for local development

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-PROPOSAL (err u101))
(define-constant ERR-ALREADY-VOTED (err u102))
(define-constant ERR-PROPOSAL-EXPIRED (err u103))
(define-constant ERR-INSUFFICIENT-FUNDS (err u104))
(define-constant ERR-ZERO-AMOUNT (err u105))
(define-constant ERR-INVALID-STATUS (err u106))
(define-constant ERR-SELF-DELEGATION (err u107))
(define-constant ERR-INVALID-TITLE-LENGTH (err u108))
(define-constant ERR-INVALID-DESC-LENGTH (err u109))

;; Data Maps
(define-map proposals 
    { proposal-id: uint }
    {
        title: (string-utf8 256),
        description: (string-utf8 1024),
        amount: uint,
        proposer: principal,
        votes-for: uint,
        votes-against: uint,
        status: (string-ascii 6),
        end-block: uint
    }
)

(define-map votes 
    { voter: principal, proposal-id: uint } 
    { voted: bool }
)

(define-map member-details
    { member: principal }
    { reputation: uint }
)

;; Constants
(define-constant VOTING_PERIOD u1440) ;; ~10 days in blocks
(define-constant MIN_PROPOSAL_AMOUNT u1000000) ;; in microSTX
(define-constant REQUIRED_APPROVAL_PERCENTAGE u70)

;; Variables
(define-data-var proposal-count uint u0)
(define-data-var dao-treasury uint u0)

;; Authorization check
(define-private (is-dao-member (user principal))
    (match (map-get? member-details { member: user })
        member-info true
        false))

;; Proposal Management
(define-public (submit-proposal (title (string-utf8 256)) 
                              (description (string-utf8 1024))
                              (amount uint))
    (let ((proposal-id (var-get proposal-count)))
        (asserts! (is-dao-member tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (>= amount MIN_PROPOSAL_AMOUNT) ERR-INVALID-PROPOSAL)
        (asserts! (> (len title) u0) ERR-INVALID-TITLE-LENGTH)
        (asserts! (> (len description) u0) ERR-INVALID-DESC-LENGTH)
        (asserts! (> amount u0) ERR-ZERO-AMOUNT)

        (map-set proposals
            { proposal-id: proposal-id }
            {
                title: title,
                description: description,
                amount: amount,
                proposer: tx-sender,
                votes-for: u0,
                votes-against: u0,
                status: "active",
                end-block: (+ stacks-block-height VOTING_PERIOD)
            }
        )

        (var-set proposal-count (+ proposal-id u1))
        (ok proposal-id)))

;; Voting System
(define-public (cast-vote (proposal-id uint) (vote-for bool))
    (let ((proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) ERR-INVALID-PROPOSAL))
          (voter-status (default-to { voted: false } 
                        (map-get? votes { voter: tx-sender, proposal-id: proposal-id }))))

        (asserts! (is-dao-member tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (not (get voted voter-status)) ERR-ALREADY-VOTED)
        (asserts! (<= stacks-block-height (get end-block proposal)) ERR-PROPOSAL-EXPIRED)

        (map-set votes 
            { voter: tx-sender, proposal-id: proposal-id }
            { voted: true })

        (if vote-for
            (map-set proposals { proposal-id: proposal-id }
                (merge proposal { votes-for: (+ (get votes-for proposal) u1) }))
            (map-set proposals { proposal-id: proposal-id }
                (merge proposal { votes-against: (+ (get votes-against proposal) u1) })))

        (ok true)))
