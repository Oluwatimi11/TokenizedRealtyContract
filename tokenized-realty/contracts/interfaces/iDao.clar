;; Interface for DAO
(define-trait iDao
  (
    ;; Initiates a multi-signature operation
    (initiate-multi-sig-operation
      ((string-utf8 64) (buff 32))
      (response uint uint)
    )
    
    ;; Signs an existing multi-signature operation
    (sign-multi-sig-operation
      (uint principal (buff 32))
      (response bool uint)
    )
    
    ;; Executes a completed multi-signature operation
    (execute-multi-sig-operation
      (uint)
      (response bool uint)
    )
    
    ;; Updates the system's operational status
    (set-system-status
      (bool)
      (response bool uint)
    )

    ;; Initializes the DAO
    (init-dao () (response bool uint))
  )
)
