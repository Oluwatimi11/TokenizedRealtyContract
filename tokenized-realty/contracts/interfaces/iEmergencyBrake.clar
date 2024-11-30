(define-trait iEmergencyBrake
    (
        ;; Initialize the emergency brake
        (init-emergency-brake 
            ()
            (response bool uint)
        )

        ;; Trigger emergency shutdown
        (trigger-emergency-shutdown 
            ((string-utf8 256))
            (response bool uint)
        )
    )
)