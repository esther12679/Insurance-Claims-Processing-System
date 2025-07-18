;; Settlement Payment Contract
;; Automates approved claim disbursements

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-CLAIM-NOT-FOUND (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-INSUFFICIENT-BALANCE (err u106))
(define-constant ERR-ALREADY-PROCESSED (err u107))

;; Data Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var total-reserves uint u0)
(define-data-var settlement-counter uint u0)

;; Data Maps
(define-map settlements uint {
    claim-id: uint,
    beneficiary: principal,
    amount: uint,
    settlement-date: uint,
    status: (string-ascii 20),
    transaction-id: (optional (buff 32))
})

(define-map claim-settlements uint uint)
(define-map pending-payments uint bool)

;; Private Functions
(define-private (is-authorized (caller principal))
    (or (is-eq caller (var-get contract-owner))
        (is-eq caller tx-sender)))

(define-private (has-sufficient-reserves (amount uint))
    (>= (var-get total-reserves) amount))

;; Public Functions
(define-public (deposit-reserves (amount uint))
    (begin
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set total-reserves (+ (var-get total-reserves) amount))
        (ok true)))

(define-public (process-settlement (claim-id uint) (beneficiary principal) (amount uint))
    (let ((settlement-id (+ (var-get settlement-counter) u1)))
        (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (asserts! (has-sufficient-reserves amount) ERR-INSUFFICIENT-BALANCE)
        (asserts! (is-none (map-get? claim-settlements claim-id)) ERR-ALREADY-PROCESSED)

        ;; Create settlement record
        (map-set settlements settlement-id {
            claim-id: claim-id,
            beneficiary: beneficiary,
            amount: amount,
            settlement-date: block-height,
            status: "pending",
            transaction-id: none
        })

        ;; Link claim to settlement
        (map-set claim-settlements claim-id settlement-id)
        (map-set pending-payments settlement-id true)

        ;; Increment counter
        (var-set settlement-counter settlement-id)
        (ok settlement-id)))

(define-public (execute-payment (settlement-id uint))
    (match (map-get? settlements settlement-id)
        settlement (begin
            (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
            (asserts! (is-eq (get status settlement) "pending") ERR-ALREADY-PROCESSED)
            (asserts! (has-sufficient-reserves (get amount settlement)) ERR-INSUFFICIENT-BALANCE)

            ;; Execute STX transfer
            (match (as-contract (stx-transfer? (get amount settlement) tx-sender (get beneficiary settlement)))
                success (begin
                    ;; Update settlement status
                    (map-set settlements settlement-id (merge settlement {
                        status: "completed",
                        transaction-id: (some 0x00) ;; Simplified transaction ID
                    }))

                    ;; Update reserves
                    (var-set total-reserves (- (var-get total-reserves) (get amount settlement)))

                    ;; Remove from pending
                    (map-delete pending-payments settlement-id)
                    (ok true))
                error ERR-INSUFFICIENT-BALANCE))
        ERR-CLAIM-NOT-FOUND))

(define-public (cancel-settlement (settlement-id uint))
    (match (map-get? settlements settlement-id)
        settlement (begin
            (asserts! (is-authorized tx-sender) ERR-NOT-AUTHORIZED)
            (asserts! (is-eq (get status settlement) "pending") ERR-ALREADY-PROCESSED)

            ;; Update status
            (map-set settlements settlement-id (merge settlement { status: "cancelled" }))
            (map-delete pending-payments settlement-id)
            (ok true))
        ERR-CLAIM-NOT-FOUND))

(define-public (withdraw-reserves (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (>= (var-get total-reserves) amount) ERR-INSUFFICIENT-BALANCE)

        (match (as-contract (stx-transfer? amount tx-sender (var-get contract-owner)))
            success (begin
                (var-set total-reserves (- (var-get total-reserves) amount))
                (ok true))
            error ERR-INSUFFICIENT-BALANCE)))

;; Read-only Functions
(define-read-only (get-settlement (settlement-id uint))
    (map-get? settlements settlement-id))

(define-read-only (get-claim-settlement (claim-id uint))
    (match (map-get? claim-settlements claim-id)
        settlement-id (map-get? settlements settlement-id)
        none))

(define-read-only (get-total-reserves)
    (var-get total-reserves))

(define-read-only (get-settlement-counter)
    (var-get settlement-counter))

(define-read-only (is-payment-pending (settlement-id uint))
    (default-to false (map-get? pending-payments settlement-id)))

(define-read-only (get-contract-balance)
    (stx-get-balance (as-contract tx-sender)))
