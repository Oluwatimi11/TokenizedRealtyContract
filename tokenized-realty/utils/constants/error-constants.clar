;;Error code definitions

(define-trait iErrorConstants (
    ;; Error constants as readable constants
    (ERR-SAME-CURRENCY () (response uint uint))
    (ERR-CURRENCY-NOT-FOUND () (response uint uint))
    (ERR-INVALID-RATE () (response uint uint))
    (ERR-RATE-OUT-OF-BOUNDS () (response uint uint))

    (ERR-UNAUTHORIZED (err u101))

    ;;amm.clar
    (ERR-CURRENCY-NOT-FOUND () (response uint uint))
    (ERR-INVALID-RATE () (response uint uint))
    (ERR-RATE-OUT-OF-BOUNDS () (response uint uint))
    (ERR-SAME-CURRENCY () (response uint uint))

    ;; fee-manager.clar
    (ERR-TAX-CALCULATION () (response uint uint))
    (ERR-TAX-CONFIGURATION-MISSING () (response uint uint))


    ;; liquidity-pool.clar
    (ERR-INVALID-PROPERTY () (response uint uint))
    (ERR-BATCH-NOT-FOUND () (response uint uint))
    (ERR-INVALID-BATCH-SIZE () (response uint uint))
    (ERR-BATCH-SIZE-EXCEEDED () (response uint uint))


    ;; dao.clar
    (ERR-SIGNATURE-REQUIRED () (response uint uint))
    (ERR-OPERATION-NOT-FOUND () (response uint uint))
    (ERR-INSUFFICIENT-SIGNATURES () (response uint uint))
    (ERR-ALREADY-SIGNED () (response uint uint))
    (ERR-SYSTEM-INACTIVE () (response uint uint))
))


    (impl-trait .utils.constants.error-constants.iErrorConstants)

    ;; Error constants implementation
    ;;General
    (define-constant ERR-UNAUTHORIZED (err u101))

    ;;amm.clar
    (define-constant ERR-CURRENCY-NOT-FOUND (err u404))
    (define-constant ERR-INVALID-RATE (err u400))
    (define-constant ERR-RATE-OUT-OF-BOUNDS (err u401))
    (define-constant ERR-SAME-CURRENCY (err u402))

    ;; fee-manager.clar
    (define-constant ERR-TAX-CALCULATION (err u1001))
    (define-constant ERR-TAX-CONFIGURATION-MISSING (err u1002))


    ;; liquidity-pool.clar
    (define-constant ERR-INVALID-PROPERTY (err u1001))
    (define-constant ERR-BATCH-NOT-FOUND (err u1002))
    (define-constant ERR-INVALID-BATCH-SIZE (err u1003))
    (define-constant ERR-BATCH-SIZE-EXCEEDED (err u1004))


    ;; dao.clar
    (define-constant ERR-SIGNATURE-REQUIRED (err u100))
    (define-constant ERR-OPERATION-NOT-FOUND (err u102))
    (define-constant ERR-INSUFFICIENT-SIGNATURES (err u103))
    (define-constant ERR-ALREADY-SIGNED (err u104))
    (define-constant ERR-SYSTEM-INACTIVE (err u105))


    ;; emergency-brake.clars
