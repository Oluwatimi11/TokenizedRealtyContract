(define-contract emergency-brake-tests)

(use-trait iEmergencyStop .utils.helpers.emergency)
(use-trait iEventLogger .utils.helpers.events)
(use-trait iErrorConstants .utils.constants.error-constants)

;; Testing the emergency stop functionality
(define-public (test-trigger-emergency)
  (begin
    (try! (contract-call? iEventLogger log-event
        "Test Emergency Stop"
        (buff-from-utf8 "Testing emergency stop trigger.")
        "INFO"
        none
    ))

    ;; Trigger the emergency stop
    (try! (contract-call? iEmergencyStop trigger-emergency))

    ;; Check if the emergency stop is active
    (let ((emergency-active (contract-call? iEmergencyStop is-emergency-active)))
      (if emergency-active
        (ok "Emergency stop is active.")
        (err ERR-EMERGENCY-ACTIVE)
      )
    )
  )
)

(define-public (test-retrieve-metrics-during-emergency)
  (begin
    ;; Trigger the emergency stop to simulate an emergency
    (try! (contract-call? iEmergencyStop trigger-emergency))

    ;; Now attempt to retrieve property metrics during an emergency
    (let ((response (contract-call? .interfaces.iMetrics get-property-performance-metrics 1)))
      (match response
        ((err ERR-EMERGENCY-ACTIVE) 
          (ok "Emergency active, metrics retrieval blocked"))
        (_ 
          (err "Metrics retrieval should have been blocked during emergency.")
        )
      )
    )
  )
)

(define-public (test-retrieve-metrics-after-emergency)
  (begin
    ;; Deactivate the emergency stop
    (try! (contract-call? iEmergencyStop deactivate-emergency))

    ;; Now attempt to retrieve property metrics after emergency stop is deactivated
    (let ((response (contract-call? .interfaces.iMetrics get-property-performance-metrics 1)))
      (match response
        ((ok metrics) 
          (ok "Metrics successfully retrieved"))
        (_ 
          (err "Metrics retrieval failed after emergency deactivation.")
        )
      )
    )
  )
)

(define-public (test-log-event-on-emergency)
  (begin
    ;; Trigger the emergency stop and check the event log
    (try! (contract-call? iEmergencyStop trigger-emergency))

    ;; Verify that an event has been logged for emergency stop
    (let ((event-logs (map-get? .utils.helpers.events.event-logs 1))) ;; Assuming event ID 1
      (if event-logs
        (ok "Emergency event logged successfully.")
        (err "Failed to log emergency event.")
      )
    )
  )
)

;; Running all the tests
(define-public (run-tests)
  (begin
    (test-trigger-emergency)
    (test-retrieve-metrics-during-emergency)
    (test-retrieve-metrics-after-emergency)
    (test-log-event-on-emergency)
  )
)
