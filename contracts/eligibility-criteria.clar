;; Eligibility Criteria Contract
;; Records service requirements and eligibility rules

(define-data-var contract-owner principal tx-sender)

;; Data structure for service types
(define-map service-types
  { service-id: (string-ascii 36) }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    is-active: bool
  }
)

;; Data structure for eligibility criteria
(define-map eligibility-criteria
  {
    service-id: (string-ascii 36),
    criteria-id: (string-ascii 36)
  }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    min-age: uint,
    max-age: uint,
    income-threshold: uint,
    required-documents: (list 10 (string-ascii 100)),
    is-active: bool
  }
)

;; Initialize contract
(define-public (initialize)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok true)
  )
)

;; Add a new service type
(define-public (add-service-type
    (service-id (string-ascii 36))
    (name (string-ascii 100))
    (description (string-ascii 500)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (asserts! (is-none (map-get? service-types { service-id: service-id })) (err u2))

    (map-set service-types
      { service-id: service-id }
      {
        name: name,
        description: description,
        is-active: true
      }
    )
    (ok true)
  )
)

;; Update a service type
(define-public (update-service-type
    (service-id (string-ascii 36))
    (name (string-ascii 100))
    (description (string-ascii 500))
    (is-active bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (asserts! (is-some (map-get? service-types { service-id: service-id })) (err u3))

    (map-set service-types
      { service-id: service-id }
      {
        name: name,
        description: description,
        is-active: is-active
      }
    )
    (ok true)
  )
)

;; Add eligibility criteria for a service
(define-public (add-eligibility-criteria
    (service-id (string-ascii 36))
    (criteria-id (string-ascii 36))
    (name (string-ascii 100))
    (description (string-ascii 500))
    (min-age uint)
    (max-age uint)
    (income-threshold uint)
    (required-documents (list 10 (string-ascii 100))))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (asserts! (is-some (map-get? service-types { service-id: service-id })) (err u3))
    (asserts! (is-none (map-get? eligibility-criteria { service-id: service-id, criteria-id: criteria-id })) (err u4))

    (map-set eligibility-criteria
      { service-id: service-id, criteria-id: criteria-id }
      {
        name: name,
        description: description,
        min-age: min-age,
        max-age: max-age,
        income-threshold: income-threshold,
        required-documents: required-documents,
        is-active: true
      }
    )
    (ok true)
  )
)

;; Update eligibility criteria
(define-public (update-eligibility-criteria
    (service-id (string-ascii 36))
    (criteria-id (string-ascii 36))
    (name (string-ascii 100))
    (description (string-ascii 500))
    (min-age uint)
    (max-age uint)
    (income-threshold uint)
    (required-documents (list 10 (string-ascii 100)))
    (is-active bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (asserts! (is-some (map-get? eligibility-criteria { service-id: service-id, criteria-id: criteria-id })) (err u5))

    (map-set eligibility-criteria
      { service-id: service-id, criteria-id: criteria-id }
      {
        name: name,
        description: description,
        min-age: min-age,
        max-age: max-age,
        income-threshold: income-threshold,
        required-documents: required-documents,
        is-active: is-active
      }
    )
    (ok true)
  )
)

;; Get service type information (read-only)
(define-read-only (get-service-type (service-id (string-ascii 36)))
  (map-get? service-types { service-id: service-id })
)

;; Get eligibility criteria (read-only)
(define-read-only (get-eligibility-criteria (service-id (string-ascii 36)) (criteria-id (string-ascii 36)))
  (map-get? eligibility-criteria { service-id: service-id, criteria-id: criteria-id })
)

;; List all required documents for a service (read-only)
(define-read-only (get-required-documents (service-id (string-ascii 36)) (criteria-id (string-ascii 36)))
  (default-to (list) (get required-documents (map-get? eligibility-criteria { service-id: service-id, criteria-id: criteria-id })))
)
