;; Citizen Identity Contract
;; Manages resident information and identity verification

(define-data-var contract-owner principal tx-sender)

;; Data structure for citizen information
(define-map citizens
  { citizen-id: (string-ascii 36) }  ;; Unique identifier for each citizen
  {
    name: (string-ascii 100),
    address: (string-ascii 200),
    birth-date: uint,  ;; Unix timestamp
    is-verified: bool,
    verification-date: uint,  ;; Unix timestamp
    verification-authority: principal
  }
)

;; List of authorized verifiers
(define-map authorized-verifiers
  { verifier: principal }
  { is-active: bool }
)

;; Initialize contract
(define-public (initialize)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok true)
  )
)

;; Add a new citizen
(define-public (register-citizen
    (citizen-id (string-ascii 36))
    (name (string-ascii 100))
    (address (string-ascii 200))
    (birth-date uint))
  (begin
    (asserts! (is-authorized-verifier tx-sender) (err u2))
    (asserts! (is-none (map-get? citizens { citizen-id: citizen-id })) (err u3))

    (map-set citizens
      { citizen-id: citizen-id }
      {
        name: name,
        address: address,
        birth-date: birth-date,
        is-verified: false,
        verification-date: u0,
        verification-authority: tx-sender
      }
    )
    (ok true)
  )
)

;; Verify a citizen's identity
(define-public (verify-citizen (citizen-id (string-ascii 36)))
  (let ((citizen-data (unwrap! (map-get? citizens { citizen-id: citizen-id }) (err u4))))
    (asserts! (is-authorized-verifier tx-sender) (err u2))

    (map-set citizens
      { citizen-id: citizen-id }
      (merge citizen-data {
        is-verified: true,
        verification-date: block-height,
        verification-authority: tx-sender
      })
    )
    (ok true)
  )
)

;; Add a new authorized verifier
(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (map-set authorized-verifiers
      { verifier: verifier }
      { is-active: true }
    )
    (ok true)
  )
)

;; Remove an authorized verifier
(define-public (remove-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (map-delete authorized-verifiers { verifier: verifier })
    (ok true)
  )
)

;; Check if a principal is an authorized verifier
(define-private (is-authorized-verifier (verifier principal))
  (default-to false (get is-active (map-get? authorized-verifiers { verifier: verifier })))
)

;; Get citizen information (read-only)
(define-read-only (get-citizen-info (citizen-id (string-ascii 36)))
  (map-get? citizens { citizen-id: citizen-id })
)

;; Check if a citizen is verified (read-only)
(define-read-only (is-citizen-verified (citizen-id (string-ascii 36)))
  (default-to false (get is-verified (map-get? citizens { citizen-id: citizen-id })))
)
