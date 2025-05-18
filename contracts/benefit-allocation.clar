;; Benefit Allocation Contract
;; Manages service distribution and benefit allocation

(define-data-var contract-owner principal tx-sender)

;; Data structure for benefit allocations
(define-map benefit-allocations
  {
    citizen-id: (string-ascii 36),
    service-id: (string-ascii 36),
    allocation-id: (string-ascii 36)
  }
  {
    amount: uint,
    start-date: uint,  ;; Block height
    end-date: uint,    ;; Block height
    status: (string-ascii 20),  ;; "active", "expired", "revoked"
    allocation-authority: principal,
    last-updated: uint  ;; Block height
  }
)

;; Data structure for benefit claims
(define-map benefit-claims
  {
    citizen-id: (string-ascii 36),
    service-id: (string-ascii 36),
    allocation-id: (string-ascii 36),
    claim-id: (string-ascii 36)
  }
  {
    amount: uint,
    claim-date: uint,  ;; Block height
    status: (string-ascii 20),  ;; "pending", "approved", "rejected"
    processor: principal,
    processing-date: uint  ;; Block height
  }
)

;; List of authorized benefit administrators
(define-map authorized-administrators
  { administrator: principal }
  { is-active: bool }
)

;; Initialize contract
(define-public (initialize)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok true)
  )
)

;; Add a new authorized administrator
(define-public (add-administrator (administrator principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (map-set authorized-administrators
      { administrator: administrator }
      { is-active: true }
    )
    (ok true)
  )
)

;; Remove an authorized administrator
(define-public (remove-administrator (administrator principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (map-delete authorized-administrators { administrator: administrator })
    (ok true)
  )
)

;; Check if a principal is an authorized administrator
(define-private (is-authorized-administrator (administrator principal))
  (default-to false (get is-active (map-get? authorized-administrators { administrator: administrator })))
)

;; Allocate a benefit to a citizen
(define-public (allocate-benefit
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (allocation-id (string-ascii 36))
    (amount uint)
    (duration uint))  ;; Duration in blocks
  (begin
    (asserts! (is-authorized-administrator tx-sender) (err u2))
    (asserts! (is-none (map-get? benefit-allocations {
      citizen-id: citizen-id,
      service-id: service-id,
      allocation-id: allocation-id
    })) (err u3))

    (map-set benefit-allocations
      {
        citizen-id: citizen-id,
        service-id: service-id,
        allocation-id: allocation-id
      }
      {
        amount: amount,
        start-date: block-height,
        end-date: (+ block-height duration),
        status: "active",
        allocation-authority: tx-sender,
        last-updated: block-height
      }
    )
    (ok true)
  )
)

;; Revoke a benefit allocation
(define-public (revoke-benefit
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (allocation-id (string-ascii 36)))
  (let ((allocation (unwrap! (map-get? benefit-allocations {
          citizen-id: citizen-id,
          service-id: service-id,
          allocation-id: allocation-id
        }) (err u4))))
    (asserts! (is-authorized-administrator tx-sender) (err u2))
    (asserts! (is-eq (get status allocation) "active") (err u5))

    (map-set benefit-allocations
      {
        citizen-id: citizen-id,
        service-id: service-id,
        allocation-id: allocation-id
      }
      (merge allocation {
        status: "revoked",
        last-updated: block-height
      })
    )
    (ok true)
  )
)

;; Claim a benefit
(define-public (claim-benefit
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (allocation-id (string-ascii 36))
    (claim-id (string-ascii 36))
    (amount uint))
  (let ((allocation (unwrap! (map-get? benefit-allocations {
          citizen-id: citizen-id,
          service-id: service-id,
          allocation-id: allocation-id
        }) (err u4))))
    (asserts! (is-eq (get status allocation) "active") (err u5))
    (asserts! (<= block-height (get end-date allocation)) (err u6))
    (asserts! (<= amount (get amount allocation)) (err u7))
    (asserts! (is-none (map-get? benefit-claims {
      citizen-id: citizen-id,
      service-id: service-id,
      allocation-id: allocation-id,
      claim-id: claim-id
    })) (err u8))

    (map-set benefit-claims
      {
        citizen-id: citizen-id,
        service-id: service-id,
        allocation-id: allocation-id,
        claim-id: claim-id
      }
      {
        amount: amount,
        claim-date: block-height,
        status: "pending",
        processor: tx-sender,
        processing-date: u0
      }
    )
    (ok true)
  )
)

;; Process a benefit claim
(define-public (process-claim
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (allocation-id (string-ascii 36))
    (claim-id (string-ascii 36))
    (status (string-ascii 20)))
  (let ((claim (unwrap! (map-get? benefit-claims {
          citizen-id: citizen-id,
          service-id: service-id,
          allocation-id: allocation-id,
          claim-id: claim-id
        }) (err u9))))
    (asserts! (is-authorized-administrator tx-sender) (err u2))
    (asserts! (is-eq (get status claim) "pending") (err u10))
    (asserts! (or (is-eq status "approved") (is-eq status "rejected")) (err u11))

    (map-set benefit-claims
      {
        citizen-id: citizen-id,
        service-id: service-id,
        allocation-id: allocation-id,
        claim-id: claim-id
      }
      (merge claim {
        status: status,
        processor: tx-sender,
        processing-date: block-height
      })
    )
    (ok true)
  )
)

;; Get benefit allocation (read-only)
(define-read-only (get-benefit-allocation
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (allocation-id (string-ascii 36)))
  (map-get? benefit-allocations {
    citizen-id: citizen-id,
    service-id: service-id,
    allocation-id: allocation-id
  })
)

;; Get benefit claim (read-only)
(define-read-only (get-benefit-claim
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (allocation-id (string-ascii 36))
    (claim-id (string-ascii 36)))
  (map-get? benefit-claims {
    citizen-id: citizen-id,
    service-id: service-id,
    allocation-id: allocation-id,
    claim-id: claim-id
  })
)

;; Check if a benefit allocation is active (read-only)
(define-read-only (is-benefit-active
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (allocation-id (string-ascii 36)))
  (let ((allocation (default-to
        {
          amount: u0,
          start-date: u0,
          end-date: u0,
          status: "expired",
          allocation-authority: tx-sender,
          last-updated: u0
        }
        (map-get? benefit-allocations {
          citizen-id: citizen-id,
          service-id: service-id,
          allocation-id: allocation-id
        }))))
    (and
      (is-eq (get status allocation) "active")
      (<= block-height (get end-date allocation))
    )
  )
)
