;; iLiquidity Interface

(define-trait iLiquidity
    (
        ;; Starts a batch distribution for a property
        (start-batch-distribution (uint uint) (response uint uint))

        ;; Retrieves the status of a batch operation
        (get-batch-status (uint) (response {operation-type: (string-utf8 64), total-items: uint, processed-items: uint, start-time: uint, end-time: uint, status: (string-utf8 20), error-count: uint} uint))

        ;; Pauses batch processing
        (pause-batch-processing (uint (string-utf8 256)) (response bool uint))

        ;; Resumes batch processing
        (resume-batch-processing (uint) (response bool uint))

        (execute (principal) (response bool uint))
    )
)
