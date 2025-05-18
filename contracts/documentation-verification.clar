;; Documentation Verification Contract
;; Validates supporting materials for service eligibility

(define-data-var contract-owner principal tx-sender)

;; Data structure for document submissions
(define-map document-submissions
  {
    citizen-id: (string-ascii 36),
    service-id: (string-ascii 36),
    submission-id: (string-ascii 36)
  }
  {
    documents: (list 10 {
      document-type: (string-ascii 100),
      document-hash: (buff 32),  ;; SHA-256 hash of document
      submission-date: uint,     ;; Block height
      is-verified: bool,
      verification-date: uint,   ;; Block height
      verifier: principal
    }),
    status: (string-ascii 20),   ;; "pending", "approved", "rejected"
    notes: (string-ascii 500)
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

;; Submit documents for verification
(define-public (submit-documents
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (submission-id (string-ascii 36))
    (documents (list 10 {
      document-type: (string-ascii 100),
      document-hash: (buff 32)
    })))
  (begin
    (asserts! (is-none (map-get? document-submissions {
      citizen-id: citizen-id,
      service-id: service-id,
      submission-id: submission-id
    })) (err u2))

    (map-set document-submissions
      {
        citizen-id: citizen-id,
        service-id: service-id,
        submission-id: submission-id
      }
      {
        documents: (map add-submission-metadata documents),
        status: "pending",
        notes: ""
      }
    )
    (ok true)
  )
)

;; Helper function to add metadata to submitted documents
(define-private (add-submission-metadata (doc {
    document-type: (string-ascii 100),
    document-hash: (buff 32)
  }))
  {
    document-type: (get document-type doc),
    document-hash: (get document-hash doc),
    submission-date: block-height,
    is-verified: false,
    verification-date: u0,
    verifier: tx-sender
  }
)

;; Verify submitted documents
(define-public (verify-documents
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (submission-id (string-ascii 36))
    (status (string-ascii 20))
    (notes (string-ascii 500)))
  (let ((submission (unwrap! (map-get? document-submissions {
          citizen-id: citizen-id,
          service-id: service-id,
          submission-id: submission-id
        }) (err u3))))
    (asserts! (is-authorized-verifier tx-sender) (err u4))
    (asserts! (or (is-eq status "approved") (is-eq status "rejected")) (err u5))

    (map-set document-submissions
      {
        citizen-id: citizen-id,
        service-id: service-id,
        submission-id: submission-id
      }
      (merge submission {
        documents: (map verify-document (get documents submission)),
        status: status,
        notes: notes
      })
    )
    (ok true)
  )
)

;; Helper function to mark documents as verified
(define-private (verify-document (doc {
    document-type: (string-ascii 100),
    document-hash: (buff 32),
    submission-date: uint,
    is-verified: bool,
    verification-date: uint,
    verifier: principal
  }))
  (merge doc {
    is-verified: true,
    verification-date: block-height,
    verifier: tx-sender
  })
)

;; Get document submission (read-only)
(define-read-only (get-document-submission
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (submission-id (string-ascii 36)))
  (map-get? document-submissions {
    citizen-id: citizen-id,
    service-id: service-id,
    submission-id: submission-id
  })
)

;; Check if documents are verified (read-only)
(define-read-only (are-documents-verified
    (citizen-id (string-ascii 36))
    (service-id (string-ascii 36))
    (submission-id (string-ascii 36)))
  (let ((submission (default-to
        {
          documents: (list),
          status: "pending",
          notes: ""
        }
        (map-get? document-submissions {
          citizen-id: citizen-id,
          service-id: service-id,
          submission-id: submission-id
        }))))
    (is-eq (get status submission) "approved")
  )
)
