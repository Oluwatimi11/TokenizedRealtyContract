(define-contract metrics-test)

(use-trait iMetrics .interfaces.iMetrics)
(use-trait iEventLogger .utils.helpers.events)
(use-trait iErrorConstants .utils.constants.error-constants)
(use-trait iEmergencyStop .utils.helpers.emergency) ;; Assuming you have this trait

;; Setup contract deployment and initialization
(define-public (test-init-metrics)
  (begin
    ;; Test if the metrics contract initializes correctly
    (asserts! (contract-call? .metrics init-metrics) "Metrics Initialization Failed")
    ;; Test that an event is logged on initialization
    (let ((event-logs (contract-call? iEventLogger get-event-logs)))
      (asserts! (is-eq (get event-logs 0 'event-type) "Metrics Initialization") "Event Log not created")
    )
    (ok true)
  )
)

;; Test for valid property metrics retrieval
(define-public (test-get-property-metrics-valid)
  (begin
    ;; Setup: Insert a valid property into the property-metrics map
    (contract-call? .metrics set-property-metrics
      1 ;; Property ID
      {
        financial-metrics: { roi: u10, occupancy-rate: u90, yield: u8, appreciation: u5 },
        risk-metrics: { volatility: u3, market-correlation: u7, liquidity-score: u2 },
        operational-metrics: { maintenance-costs: u500, tenant-satisfaction: u95, energy-efficiency: u80 }
      }
    )

    ;; Test: Retrieve the valid property metrics
    (let ((result (contract-call? .metrics get-property-performance-metrics 1)))
      (asserts! (is-eq (get result 'financial-metrics) { roi: u10, occupancy-rate: u90, yield: u8, appreciation: u5 }) "Incorrect financial metrics")
      (asserts! (is-eq (get result 'risk-metrics) { volatility: u3, market-correlation: u7, liquidity-score: u2 }) "Incorrect risk metrics")
      (asserts! (is-eq (get result 'operational-metrics) { maintenance-costs: u500, tenant-satisfaction: u95, energy-efficiency: u80 }) "Incorrect operational metrics")
    )
    (ok true)
  )
)

;; Test for invalid property ID (non-existent property)
(define-public (test-get-property-metrics-invalid)
  (begin
    ;; Test: Retrieve metrics for a non-existent property
    (let ((result (contract-call? .metrics get-property-performance-metrics 999)))
      (asserts! (is-eq result (err ERR-INVALID-PROPERTY)) "Failed to return the correct error for invalid property ID")
    )
    (ok true)
  )
)

;; Test that emergency stop prevents property metrics retrieval
(define-public (test-emergency-stop)
  (begin
    ;; Setup: Trigger the emergency stop
    (contract-call? .emergency trigger-emergency)

    ;; Test: Try retrieving property metrics after the emergency stop
    (let ((result (contract-call? .metrics get-property-performance-metrics 1)))
      (asserts! (is-eq result (err ERR-EMERGENCY-ACTIVE)) "Failed to block metrics retrieval during emergency stop")
    )

    ;; Test: Log the emergency stop event
    (let ((event-logs (contract-call? iEventLogger get-event-logs)))
      (asserts! (is-eq (get event-logs 0 'event-type) "Emergency Stop Triggered") "Event for emergency stop not logged")
    )
    (ok true)
  )
)

;; Test for logging events on successful retrieval
(define-public (test-log-events-success)
  (begin
    ;; Setup: Insert a valid property into the property-metrics map
    (contract-call? .metrics set-property-metrics
      2 ;; Property ID
      {
        financial-metrics: { roi: u12, occupancy-rate: u88, yield: u7, appreciation: u6 },
        risk-metrics: { volatility: u2, market-correlation: u8, liquidity-score: u4 },
        operational-metrics: { maintenance-costs: u400, tenant-satisfaction: u98, energy-efficiency: u85 }
      }
    )

    ;; Test: Retrieve the valid property metrics
    (let ((result (contract-call? .metrics get-property-performance-metrics 2)))
      (asserts! (is-eq (get result 'financial-metrics) { roi: u12, occupancy-rate: u88, yield: u7, appreciation: u6 }) "Incorrect financial metrics")
      (asserts! (is-eq (get result 'risk-metrics) { volatility: u2, market-correlation: u8, liquidity-score: u4 }) "Incorrect risk metrics")
      (asserts! (is-eq (get result 'operational-metrics) { maintenance-costs: u400, tenant-satisfaction: u98, energy-efficiency: u85 }) "Incorrect operational metrics")
      
      ;; Check if the event was logged for successful retrieval
      (let ((event-logs (contract-call? iEventLogger get-event-logs)))
        (asserts! (is-eq (get event-logs 1 'event-type) "Retrieve Metrics") "Event for successful metrics retrieval not logged")
      )
    )
    (ok true)
  )
)

;; Test for logging events on failed retrieval
(define-public (test-log-events-failure)
  (begin
    ;; Test: Attempt to retrieve metrics for a non-existent property
    (let ((result (contract-call? .metrics get-property-performance-metrics 999)))
      (asserts! (is-eq result (err ERR-INVALID-PROPERTY)) "Failed to return the correct error for invalid property ID")
      
      ;; Check if the event was logged for failed retrieval
      (let ((event-logs (contract-call? iEventLogger get-event-logs)))
        (asserts! (is-eq (get event-logs 2 'event-type) "Retrieve Metrics Failed") "Event for failed metrics retrieval not logged")
      )
    )
    (ok true)
  )
)

