(define-deploy test-deploy
  (begin
    ;; Deploy the AMM contract and any necessary helper contracts
    (contract-call? .amm init-amm)
  )
)

;; Test: Initialize AMM
(define-public (test-init-amm)
  (begin
    (let
      (
        (init-result (contract-call? .amm init-amm))
      )
      (asserts! (is-eq init-result (ok true)) "Failed to initialize AMM.")
      (ok true)
  )
))

;; Test: Update Currency Rate
(define-public (test-update-currency-rate)
  (begin
    ;; Update the conversion rate from USD to EUR
    (let
      (
        (update-result (contract-call? .amm update-currency-rate "USD" "EUR" u1200))
      )
      (asserts! (is-eq update-result (ok true)) "Failed to update currency rate.")
      (ok true)
  )
))

;; Test: Fail on same currency update
(define-public (test-update-same-currency)
  (begin
    ;; Try updating the rate for the same currency (should fail)
    (let
      (
        (update-result (contract-call? .amm update-currency-rate "USD" "USD" u1200))
      )
      (asserts! (is-eq update-result (err ERR-SAME-CURRENCY)) "Expected error when updating same currency.")
      (ok true)
  )
))

;; Test: Retrieve Currency Rate
(define-public (test-get-currency-rate)
  (begin
    ;; Ensure that the conversion rate is correctly set and retrievable
    (let
      (
        (rate-result (contract-call? .amm get-currency-rate "USD" "EUR"))
      )
      (asserts! (is-eq (get conversion-rate rate-result) u1200) "Retrieved currency rate is incorrect.")
      (ok true)
  )
))

;; Test: Currency Conversion
(define-public (test-convert-currency)
  (begin
    ;; Convert 1000 USD to EUR using the current rate
    (let
      (
        (conversion-result (contract-call? .amm convert-currency u1000 "USD" "EUR"))
      )
      (asserts! (is-eq conversion-result (ok u1200)) "Currency conversion is incorrect.")
      (ok true)
  )
))

;; Test: Fail on invalid currency rate retrieval
(define-public (test-invalid-currency-rate)
  (begin
    ;; Attempt to retrieve a non-existent rate (should fail)
    (let
      (
        (rate-result (contract-call? .amm get-currency-rate "GBP" "EUR"))
      )
      (asserts! (is-eq rate-result (err ERR-CURRENCY-NOT-FOUND)) "Expected error when retrieving non-existent currency rate.")
      (ok true)
  )
))

;; Test: Validate rate update within bounds
(define-public (test-valid-rate-update)
  (begin
    ;; Try updating the rate with a valid value
    (let
      (
        (update-result (contract-call? .amm update-currency-rate "USD" "EUR" u999999))
      )
      (asserts! (is-eq update-result (ok true)) "Failed to update currency rate with valid value.")
      (ok true)
  )
))

;; Test: Fail on invalid rate update (out of bounds)
(define-public (test-invalid-rate-update)
  (begin
    ;; Try updating the rate with an invalid value (out of bounds)
    (let
      (
        (update-result (contract-call? .amm update-currency-rate "USD" "EUR" u10000001))
      )
      (asserts! (is-eq update-result (err ERR-RATE-OUT-OF-BOUNDS)) "Expected error when updating currency rate out of bounds.")
      (ok true)
  )
))

;; Test: Emergency Stop Behavior (optional)
(define-public (test-emergency-stop)
  (begin
    ;; Trigger emergency stop and ensure further actions are blocked
    (let
      (
        (trigger-result (contract-call? .amm trigger-emergency))
      )
      (asserts! (is-eq trigger-result (ok true)) "Failed to trigger emergency stop.")
      ;; Test if retrieving a rate works after emergency stop (should fail)
      (let
        (
          (rate-result (contract-call? .amm get-currency-rate "USD" "EUR"))
        )
        (asserts! (is-eq rate-result (err ERR-EMERGENCY-ACTIVE)) "Expected error during emergency state.")
      )
      (ok true)
  )
))
