(use-trait iErrorConstants .utils.constants.error-constants)
(use-trait iEventLogger .utils.helpers.events)

;; Emergency controls and shutdown procedures

;; Define who can trigger emergency actions
(define-private (is-admin (caller principal))
  ;; Replace with actual admin check logic
  (is-eq caller tx-sender)
)

;; Initialize emergency brake with a default state
(define-public (init-emergency-brake)
  (begin
    ;; Initialize the emergency-status variable as 'false' (no emergency)
    (var-set emergency-status false)
    
    ;; Log the initialization of the emergency brake
    (try! (contract-call? iEventLogger log-event
        "Emergency Brake Initialization"
        (buff-from-utf8 "Emergency brake initialized with status 'false'.")
        "INFO"
        none
    ))
    (ok true)
  )
)

(define-data-var emergency-status bool false)

(define-map emergency-actions
    uint  ;; action-id
    {
        action-type: (string-utf8 64),
        initiator: principal,
        timestamp: uint,
        status: (string-utf8 20),
        resolution: (optional (string-utf8 256))
    }
)

;; Emergency check function that checks if emergency is active
(define-private (is-emergency-active)
  (var-get emergency-status))

;; Process emergency actions and log the details
(define-private (process-emergency-actions (reason (string-utf8 256)))
  (let ((action-id (+ block-height u1)))
    (begin
      ;; Log the emergency action
      (map-set emergency-actions action-id
        {
          action-type: "Emergency Shutdown",
          initiator: tx-sender,
          timestamp: block-height,
          status: "Triggered",
          resolution: none
        }
      )
      ;; Log event via centralized system
      (try! (contract-call? iEventLogger log-event
          "Emergency Action Processed"
          (buff-from-utf8 reason)
          "CRITICAL"
          (some action-id)
      ))
      (ok true)
    )
  )
)

;; Trigger emergency shutdown with event logging
(define-public (trigger-emergency-shutdown (reason (string-utf8 256)))
  (begin
    ;; Check if the sender is an admin
    (asserts! (is-admin tx-sender) contract-call? iErrorConstants ERR-UNAUTHORIZED)
    
    ;; Update the emergency status to 'true' and log the event
    (var-set emergency-status true)
    
    ;; Log the emergency shutdown
    (try! (contract-call? iEventLogger log-event
        "Emergency Shutdown Triggered"
        (buff-from-utf8 reason)
        "CRITICAL"
        none
    ))
    
    ;; Process the emergency actions with the provided reason
    (try! (process-emergency-actions reason))
    
    (ok true)
  )
)

;; Emergency-protected operation example
(define-public (some-restricted-operation)
  (begin
    ;; Check if emergency is active
    (asserts! (not (is-emergency-active)) ERR-EMERGENCY-ACTIVE)
    
    ;; Perform the restricted operation
    (ok "Operation executed successfully.")
  )
)

;; Emergency reset function to disable emergency status
(define-public (reset-emergency)
  (begin
    ;; Check if the sender is an admin
    (asserts! (is-admin tx-sender) contract-call? iErrorConstants ERR-UNAUTHORIZED)
    
    ;; Reset the emergency status
    (var-set emergency-status false)
    
    ;; Log the reset of the emergency status
    (try! (contract-call? iEventLogger log-event
        "Emergency Status Reset"
        (buff-from-utf8 "Emergency status has been reset to 'false'.")
        "INFO"
        none
    ))
    
    (ok true)
  )
)
