(define-constant test-pool-id u1)

(define-constant test-user (principal "ST2XG6Q7JTVJWZ2NFU5MZ2H5X7RWB8M4GJ7DNTY9R"))
(define-constant test-user-2 (principal "ST2XG6Q7JTVJWZ2NFU5MZ2H5X7RWB8M4GJ7DNTY9R"))

(define-constant liquidity-deposit-amount u500)
(define-constant liquidity-remove-amount u300)

(define-trait iLiquidity .liquidity)

(use-trait iLiquidity .utils.helpers.liquidity)
(use-trait iEventLogger .utils.helpers.events)
(use-trait iErrorConstants .utils.constants.error-constants)

(define-public (test-add-liquidity)
  (begin
    ;; Test: Add liquidity to the pool
    (contract-call? .liquidity add-liquidity test-pool-id test-user liquidity-deposit-amount)
    (let
      (
        (balance (contract-call? .liquidity get-pool-balance test-pool-id))
      )
      (asserts! (= balance liquidity-deposit-amount) ERR-LIQUIDITY-ADD-FAILED)
    )
    (ok true)
  )
)

(define-public (test-remove-liquidity)
  (begin
    ;; Test: Remove liquidity from the pool
    (contract-call? .liquidity add-liquidity test-pool-id test-user liquidity-deposit-amount) ;; Adding liquidity first
    (contract-call? .liquidity remove-liquidity test-pool-id test-user liquidity-remove-amount)
    (let
      (
        (balance (contract-call? .liquidity get-pool-balance test-pool-id))
      )
      ;; Ensure the balance is reduced after removal
      (asserts! (= balance (- liquidity-deposit-amount liquidity-remove-amount)) ERR-LIQUIDITY-REMOVE-FAILED)
    )
    (ok true)
  )
)

(define-public (test-get-pool-balance)
  (begin
    ;; Test: Check the pool balance without any liquidity added
    (let
      (
        (initial-balance (contract-call? .liquidity get-pool-balance test-pool-id))
      )
      (asserts! (= initial-balance u0) ERR-POOL-BALANCE-INITIAL)
    )
    
    ;; Test: Check the pool balance after adding liquidity
    (contract-call? .liquidity add-liquidity test-pool-id test-user liquidity-deposit-amount)
    (let
      (
        (new-balance (contract-call? .liquidity get-pool-balance test-pool-id))
      )
      (asserts! (= new-balance liquidity-deposit-amount) ERR-POOL-BALANCE-UPDATE)
    )
    (ok true)
  )
)

(define-public (test-emergency-stop)
  (begin
    ;; Test: Simulate emergency stop during liquidity add operation
    (contract-call? .liquidity add-liquidity test-pool-id test-user liquidity-deposit-amount)
    ;; Trigger emergency stop (assumed function in the liquidity contract)
    (contract-call? .liquidity trigger-emergency)
    
    ;; Try to add liquidity after emergency stop, expect failure
    (asserts! (err (get ERR-EMERGENCY-ACTIVE iErrorConstants)) ERR-EMERGENCY-ADD-FAILED)
    
    (ok true)
  )
)

