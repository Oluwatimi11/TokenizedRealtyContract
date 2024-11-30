(impl-trait .interfaces.iAMM)
(use-trait iErrorConstants .utils.constants.error-constants)
(use-trait iEventLogger .utils.helpers.events)
(use-trait iEmergency .utils.helpers.emergency)

;; Map to store currency conversion rates
(define-map currency-conversion-rates
    {
        source-currency: (string-utf8 3),
        target-currency: (string-utf8 3)
    }
    {
        conversion-rate: uint,
        last-updated: uint
    }
)

;; Initialize AMM with a default currency rate
(define-public (init-amm)
  (begin
    ;; Check if an emergency is active before proceeding
    (asserts! (not (is-emergency-active)) ERR-EMERGENCY-ACTIVE)

    ;; Set default currency rate
    (map-set currency-conversion-rates
      {
        source-currency: "USD",
        target-currency: "EUR"
      }
      {
        conversion-rate: u1000,
        last-updated: block-height
      }
    )
    
    ;; Log initialization event
    (try! (contract-call? iEventLogger log-event
        "AMM Initialization"
        (buff-from-utf8 "Initialized with default USD/EUR rate of 1000.")
        "INFO"
        none
    ))
    (ok true)
  )
)

;; Update currency conversion rate with validations
(define-public (update-currency-rate 
    (source-currency (string-utf8 3)) 
    (target-currency (string-utf8 3)) 
    (new-rate uint))
  (begin
    ;; Check if an emergency is active before proceeding
    (asserts! (not (is-emergency-active)) ERR-EMERGENCY-ACTIVE)

    (asserts! (not (is-eq source-currency target-currency)) contract-call? iErrorConstants ERR-SAME-CURRENCY)
    (try! (validate-rate-update new-rate))
    (map-set currency-conversion-rates
      {
        source-currency: source-currency,
        target-currency: target-currency
      }
      {
        conversion-rate: new-rate,
        last-updated: block-height
      }
    )
    ;; Log rate update event
    (try! (contract-call? iEventLogger log-event
        "Update Currency Rate"
        (buff-from-utf8 (concat "Updated rate for " (concat source-currency (concat " to " target-currency))))
        "INFO"
        none
    ))
    (ok true)
  )
)

;; Retrieve a specific currency rate
(define-public (get-currency-rate 
    (source-currency (string-utf8 3)) 
    (target-currency (string-utf8 3)))
  (let 
    (
      (rate (unwrap! 
        (map-get? currency-conversion-rates {
          source-currency: source-currency,
          target-currency: target-currency
        }) 
        contract-call? iErrorConstants ERR-CURRENCY-NOT-FOUND
      ))
    )
    (begin
      ;; Check if an emergency is active before proceeding
      (asserts! (not (is-emergency-active)) ERR-EMERGENCY-ACTIVE)

      ;; Log currency rate retrieval
      (try! (contract-call? iEventLogger log-event
          "Get Currency Rate"
          (buff-from-utf8 (concat "Retrieved rate for " (concat source-currency (concat " to " target-currency))))
          "INFO"
          none
      ))
      (ok rate)
    )
  )
)

;; Convert currency using available rates
(define-public (convert-currency 
    (amount uint) 
    (source-currency (string-utf8 3)) 
    (target-currency (string-utf8 3)))
  (let
    (
      (rate-data (try! (get-currency-rate source-currency target-currency)))
      (conversion-rate (get conversion-rate rate-data))
      (converted-amount (/ (* amount conversion-rate) u1000)) ;; Assuming rates are scaled integers
    )
    (begin
      ;; Check if an emergency is active before proceeding
      (asserts! (not (is-emergency-active)) ERR-EMERGENCY-ACTIVE)

      ;; Log currency conversion
      (try! (contract-call? iEventLogger log-event
          "Currency Conversion"
          (buff-from-utf8 (concat "Converted " (concat (uint-to-string amount) (concat " from " (concat source-currency (concat " to " target-currency))))))
          "INFO"
          none
      ))
      (ok converted-amount)
    )
  )
)

;; Validate the new rate for bounds
(define-private (validate-rate-update (new-rate uint))
  (begin
    (asserts! (> new-rate u0) (contract-call? iErrorConstants ERR-INVALID-RATE))
    (asserts! (< new-rate u1000000) (contract-call? iErrorConstants ERR-RATE-OUT-OF-BOUNDS)) ;; Adjust upper limit as needed
    (ok true)
  )
)
