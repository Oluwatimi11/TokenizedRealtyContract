(use-trait iAMM .iAmm.iAMM)
(use-trait iFeeManager .iFeeManager.iFeeManager)
(use-trait iLiquidity .iLiquidity.iLiquidity)
(use-trait iEmergencyBrake .iEmergencyBrake.iEmergencyBrake)
(use-trait iDao .iDao.iDao)
(use-trait iMetrics .iMetrics.iMetrics)

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-INITIALIZATION-FAILED (err u402))

;; Contract owner storage
(define-data-var contract-owner principal tx-sender)

;; Check if caller is contract owner
(define-private (is-contract-owner (caller principal))
  (is-eq caller (var-get contract-owner))
)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-UNAUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true)
  )
)

(define-public (initialize-contract 
  (amm-contract <iAMM>)
  (fee-manager-contract <iFeeManager>)
  (liquidity-pool-contract <iLiquidity>)
  (emergency-brake-contract <iEmergencyBrake>)
  (dao-contract <iDao>)
  (metrics-contract <iMetrics>)
)
  (begin
    ;; Ensure only contract owner can initialize
    (asserts! (is-contract-owner tx-sender) ERR-UNAUTHORIZED)

    ;; Initialize the AMM contract
    (unwrap! (contract-call? amm-contract execute tx-sender) ERR-INITIALIZATION-FAILED)

    ;; Initialize the Fee Manager
    (unwrap! (contract-call? fee-manager-contract execute tx-sender) ERR-INITIALIZATION-FAILED)

    ;; Initialize the Liquidity Pool
    (unwrap! (contract-call? liquidity-pool-contract execute tx-sender) ERR-INITIALIZATION-FAILED)

    ;; Set up emergency brake
    (unwrap! (contract-call? emergency-brake-contract init-emergency-brake) ERR-INITIALIZATION-FAILED)

    ;; Initialize DAO governance
    (unwrap! (contract-call? dao-contract init-dao) ERR-INITIALIZATION-FAILED)

    ;; Initialize metrics
    (unwrap! (contract-call? metrics-contract init-metrics) ERR-INITIALIZATION-FAILED)

    (ok true)
  )
)