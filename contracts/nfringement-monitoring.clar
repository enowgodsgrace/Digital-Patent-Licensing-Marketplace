;; Infringement Monitoring Contract
;; Detects and manages patent infringement cases

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PATENT-NOT-FOUND (err u101))
(define-constant ERR-INVALID-INPUT (err u102))
(define-constant ERR-CASE-NOT-FOUND (err u103))
(define-constant ERR-INVALID-STATUS (err u104))

;; Data Variables
(define-data-var next-case-id uint u1)

;; Data Maps
(define-map infringement-cases
  { case-id: uint }
  {
    patent-id: uint,
    reporter: principal,
    accused-party: principal,
    description: (string-ascii 1024),
    evidence-hash: (string-ascii 64),
    status: (string-ascii 32),
    severity: (string-ascii 16),
    reported-at: uint,
    resolved-at: (optional uint)
  }
)

(define-map case-evidence
  { case-id: uint, evidence-id: uint }
  {
    submitter: principal,
    evidence-type: (string-ascii 32),
    evidence-hash: (string-ascii 64),
    description: (string-ascii 512),
    submitted-at: uint,
    verified: bool
  }
)

(define-map case-resolutions
  { case-id: uint }
  {
    resolution-type: (string-ascii 32),
    penalty-amount: uint,
    settlement-terms: (string-ascii 512),
    resolved-by: principal,
    resolution-date: uint
  }
)

(define-map infringement-penalties
  { accused-party: principal }
  {
    total-penalties: uint,
    active-cases: uint,
    resolved-cases: uint
  }
)

(define-map evidence-counters
  { case-id: uint }
  { next-evidence-id: uint }
)

;; Public Functions

;; Report infringement case
(define-public (report-infringement
  (patent-id uint)
  (accused-party principal)
  (description (string-ascii 1024))
  (evidence-hash (string-ascii 64))
  (severity (string-ascii 16)))
  (let ((case-id (var-get next-case-id)))
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> (len evidence-hash) u0) ERR-INVALID-INPUT)
    (asserts! (not (is-eq tx-sender accused-party)) ERR-INVALID-INPUT)

    (map-set infringement-cases
      { case-id: case-id }
      {
        patent-id: patent-id,
        reporter: tx-sender,
        accused-party: accused-party,
        description: description,
        evidence-hash: evidence-hash,
        status: "open",
        severity: severity,
        reported-at: block-height,
        resolved-at: none
      }
    )

    ;; Initialize evidence counter
    (map-set evidence-counters
      { case-id: case-id }
      { next-evidence-id: u1 }
    )

    ;; Update accused party penalties
    (let ((current-penalties (default-to
                               { total-penalties: u0, active-cases: u0, resolved-cases: u0 }
                               (map-get? infringement-penalties { accused-party: accused-party }))))
      (map-set infringement-penalties
        { accused-party: accused-party }
        (merge current-penalties { active-cases: (+ (get active-cases current-penalties) u1) })
      )
    )

    (var-set next-case-id (+ case-id u1))
    (ok case-id)
  )
)

;; Submit additional evidence
(define-public (submit-evidence
  (case-id uint)
  (evidence-type (string-ascii 32))
  (evidence-hash (string-ascii 64))
  (description (string-ascii 512)))
  (let ((case-info (unwrap! (map-get? infringement-cases { case-id: case-id }) ERR-CASE-NOT-FOUND))
        (counter (unwrap! (map-get? evidence-counters { case-id: case-id }) ERR-CASE-NOT-FOUND))
        (evidence-id (get next-evidence-id counter)))
    (asserts! (is-eq (get status case-info) "open") ERR-INVALID-STATUS)
    (asserts! (> (len evidence-hash) u0) ERR-INVALID-INPUT)

    (map-set case-evidence
      { case-id: case-id, evidence-id: evidence-id }
      {
        submitter: tx-sender,
        evidence-type: evidence-type,
        evidence-hash: evidence-hash,
        description: description,
        submitted-at: block-height,
        verified: false
      }
    )

    (map-set evidence-counters
      { case-id: case-id }
      { next-evidence-id: (+ evidence-id u1) }
    )

    (ok evidence-id)
  )
)

;; Verify evidence
(define-public (verify-evidence (case-id uint) (evidence-id uint))
  (let ((evidence (unwrap! (map-get? case-evidence { case-id: case-id, evidence-id: evidence-id }) ERR-INVALID-INPUT)))
    (map-set case-evidence
      { case-id: case-id, evidence-id: evidence-id }
      (merge evidence { verified: true })
    )

    (ok true)
  )
)

;; Resolve infringement case
(define-public (resolve-case
  (case-id uint)
  (resolution-type (string-ascii 32))
  (penalty-amount uint)
  (settlement-terms (string-ascii 512)))
  (let ((case-info (unwrap! (map-get? infringement-cases { case-id: case-id }) ERR-CASE-NOT-FOUND)))
    (asserts! (or
      (is-eq tx-sender (get reporter case-info))
      (is-eq tx-sender CONTRACT-OWNER)
    ) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status case-info) "open") ERR-INVALID-STATUS)

    ;; Update case status
    (map-set infringement-cases
      { case-id: case-id }
      (merge case-info {
        status: "resolved",
        resolved-at: (some block-height)
      })
    )

    ;; Record resolution
    (map-set case-resolutions
      { case-id: case-id }
      {
        resolution-type: resolution-type,
        penalty-amount: penalty-amount,
        settlement-terms: settlement-terms,
        resolved-by: tx-sender,
        resolution-date: block-height
      }
    )

    ;; Update accused party penalties
    (let ((current-penalties (default-to
                               { total-penalties: u0, active-cases: u0, resolved-cases: u0 }
                               (map-get? infringement-penalties { accused-party: (get accused-party case-info) }))))
      (map-set infringement-penalties
        { accused-party: (get accused-party case-info) }
        {
          total-penalties: (+ (get total-penalties current-penalties) penalty-amount),
          active-cases: (- (get active-cases current-penalties) u1),
          resolved-cases: (+ (get resolved-cases current-penalties) u1)
        }
      )
    )

    (ok true)
  )
)

;; Dismiss case
(define-public (dismiss-case (case-id uint))
  (let ((case-info (unwrap! (map-get? infringement-cases { case-id: case-id }) ERR-CASE-NOT-FOUND)))
    (asserts! (or
      (is-eq tx-sender (get reporter case-info))
      (is-eq tx-sender CONTRACT-OWNER)
    ) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status case-info) "open") ERR-INVALID-STATUS)

    (map-set infringement-cases
      { case-id: case-id }
      (merge case-info {
        status: "dismissed",
        resolved-at: (some block-height)
      })
    )

    ;; Update accused party penalties
    (let ((current-penalties (default-to
                               { total-penalties: u0, active-cases: u0, resolved-cases: u0 }
                               (map-get? infringement-penalties { accused-party: (get accused-party case-info) }))))
      (map-set infringement-penalties
        { accused-party: (get accused-party case-info) }
        (merge current-penalties { active-cases: (- (get active-cases current-penalties) u1) })
      )
    )

    (ok true)
  )
)

;; Read-only Functions

;; Get case details
(define-read-only (get-case (case-id uint))
  (map-get? infringement-cases { case-id: case-id })
)

;; Get case evidence
(define-read-only (get-evidence (case-id uint) (evidence-id uint))
  (map-get? case-evidence { case-id: case-id, evidence-id: evidence-id })
)

;; Get case resolution
(define-read-only (get-resolution (case-id uint))
  (map-get? case-resolutions { case-id: case-id })
)

;; Get infringement penalties for accused party
(define-read-only (get-penalties (accused-party principal))
  (map-get? infringement-penalties { accused-party: accused-party })
)

;; Check if case is open
(define-read-only (is-case-open (case-id uint))
  (match (map-get? infringement-cases { case-id: case-id })
    case-info (is-eq (get status case-info) "open")
    false
  )
)

;; Get next case ID
(define-read-only (get-next-case-id)
  (var-get next-case-id)
)

;; Get evidence counter
(define-read-only (get-evidence-counter (case-id uint))
  (map-get? evidence-counters { case-id: case-id })
)
