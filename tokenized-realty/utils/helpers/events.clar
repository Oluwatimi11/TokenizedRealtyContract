;; Event logging system

(define-map event-logs
    uint ;; event-id
    {
        event-type: (string-utf8 64),
        timestamp: uint,
        initiator: principal,
        details: (buff 256),
        severity: (string-utf8 20),
        related-entity: (optional uint)
    }
)

;; Public function to log events (exposed for external contracts)
(define-public (log-event 
    (event-type (string-utf8 64)) 
    (details (buff 256)) 
    (severity (string-utf8 20)) 
    (related-entity (optional uint)))
  (let (
      ;; Use block-height as part of the event ID to ensure uniqueness
      (event-id (+ block-height u1))
  )
    (begin
      ;; Store the event in the map
      (map-set event-logs event-id
        {
          event-type: event-type,
          timestamp: block-height,
          initiator: tx-sender,
          details: details,
          severity: severity,
          related-entity: related-entity
        }
      )
      ;; Return the event ID for tracking purposes
      (ok event-id)
    )
  )
)

;; Read-only function to retrieve an event by ID
(define-read-only (get-event (event-id uint))
  (default-to 
    (err u404) ;; Return a not-found error if the event ID doesn't exist
    (map-get? event-logs event-id)
  )
)

;; Read-only function to check the latest event ID
(define-read-only (get-latest-event-id)
  (ok (+ block-height u1))
)
