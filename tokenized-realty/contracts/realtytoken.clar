;; title: Real Estate Asset Tokenization Contract
;; version: v1
;; summary: Implements SIP-010 token standard for fungible tokens

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Define constants
(define-constant property-developer tx-sender)
(define-constant err-unauthorized-developer (err u100))
(define-constant err-unauthorized-owner (err u101))
(define-constant err-insufficient-shares (err u102))
(define-constant err-property-not-found (err u103))
(define-constant err-invalid-valuation (err u104))

;; Define data variables
(define-data-var property-legal-documents (string-utf8 256) "")
(define-data-var total-shares-issued uint u0)

;; Data maps for share accounting
(define-map investor-shares principal uint)
(define-map authorized-brokers {property-owner: principal, broker: principal} bool)

;; Property Registry
(define-map real-estate-registry
    uint ; property-deed-id
    {
        street-address: (string-utf8 256),
        property-type: (string-utf8 64), ;; residential, commercial, industrial
        total-area-sqft: uint,
        share-price-usd: uint,
        total-shares: uint,
        construction-year: uint,
        last-valuation-date: uint,
        rental-income-annual: uint,
        occupancy-rate: uint,
        maintenance-reserve: uint
    }
)

;; Get token name
(define-read-only (get-name)
    (ok "RealEstateShareToken")
)

;; Get token symbol
(define-read-only (get-symbol)
    (ok "REST")
)

;; Get number of decimals
(define-read-only (get-decimals)
    (ok u6)
)

;; Get property legal documents
(define-read-only (get-property-documents)
    (ok (var-get property-legal-documents))
)

;; Get total shares issued
(define-read-only (get-total-shares)
    (ok (var-get total-shares-issued))
)

;; Get investor share balance
(define-read-only (get-investor-shares (investor-address principal))
    (ok (default-to u0 (map-get? investor-shares investor-address)))
)

;; Transfer property shares
(define-public (transfer-shares (share-amount uint) (current-owner principal) (new-owner principal) (transfer-memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender current-owner) err-unauthorized-owner)
        (try! (process-share-transfer share-amount current-owner new-owner))
        (match transfer-memo memo-to-record (print memo-to-record) 0x)
        (ok true)
    )
)

;; Helper function for share transfers
(define-private (process-share-transfer (share-amount uint) (current-owner principal) (new-owner principal))
    (let (
        (current-owner-shares (default-to u0 (map-get? investor-shares current-owner)))
        (new-owner-shares (default-to u0 (map-get? investor-shares new-owner)))
    )
        (asserts! (>= current-owner-shares share-amount) err-insufficient-shares)
        (map-set investor-shares current-owner (- current-owner-shares share-amount))
        (map-set investor-shares new-owner (+ new-owner-shares share-amount))
        (ok true)
    )
)

;; Issue new property shares
(define-public (issue-property-shares (share-amount uint) (investor-address principal))
    (begin
        (asserts! (is-eq tx-sender property-developer) err-unauthorized-developer)
        (try! (process-share-issuance share-amount investor-address))
        (ok true)
    )
)

;; Helper function for share issuance
(define-private (process-share-issuance (share-amount uint) (investor-address principal))
    (let (
        (current-shares (default-to u0 (map-get? investor-shares investor-address)))
        (updated-shares (+ current-shares share-amount))
    )
        (var-set total-shares-issued (+ (var-get total-shares-issued) share-amount))
        (map-set investor-shares investor-address updated-shares)
        (ok true)
    )
)

;; Register new property
(define-public (register-property 
    (deed-id uint) 
    (street-address (string-utf8 256))
    (property-type (string-utf8 64))
    (total-area-sqft uint)
    (share-price-usd uint)
    (total-shares uint)
    (construction-year uint)
    (rental-income-annual uint)
    (occupancy-rate uint)
    (maintenance-reserve uint))
    (begin
        (asserts! (is-eq tx-sender property-developer) err-unauthorized-developer)
        (map-set real-estate-registry deed-id {
            street-address: street-address,
            property-type: property-type,
            total-area-sqft: total-area-sqft,
            share-price-usd: share-price-usd,
            total-shares: total-shares,
            construction-year: construction-year,
            last-valuation-date: block-height,
            rental-income-annual: rental-income-annual,
            occupancy-rate: occupancy-rate,
            maintenance-reserve: maintenance-reserve
        })
        (ok true)
    )
)

;; Get property details
(define-read-only (get-property-details (deed-id uint))
    (map-get? real-estate-registry deed-id)
)

;; Update property valuation
(define-public (update-property-valuation (deed-id uint) (new-share-price-usd uint) (new-rental-income uint) (new-occupancy-rate uint))
    (let (
        (property (unwrap! (map-get? real-estate-registry deed-id) err-property-not-found))
    )
        (asserts! (is-eq tx-sender property-developer) err-unauthorized-developer)
        (asserts! (> new-share-price-usd u0) err-invalid-valuation)
        (map-set real-estate-registry deed-id (merge property {
            share-price-usd: new-share-price-usd,
            rental-income-annual: new-rental-income,
            occupancy-rate: new-occupancy-rate,
            last-valuation-date: block-height
        }))
        (ok true)
    )
)

;; Set property legal documents
(define-public (set-property-documents (new-documents (string-utf8 256)))
    (begin
        (asserts! (is-eq tx-sender property-developer) err-unauthorized-developer)
        (var-set property-legal-documents new-documents)
        (ok true)
    )
)

;; Calculate property metrics
(define-read-only (get-property-metrics (deed-id uint))
    (let (
        (property (unwrap! (map-get? real-estate-registry deed-id) err-property-not-found))
    )
        (ok {
            market-cap: (* (get share-price-usd property) (get total-shares property)),
            annual-yield: (/ (* (get rental-income-annual property) u100) 
                            (* (get share-price-usd property) (get total-shares property))),
            sqft-price: (/ (* (get share-price-usd property) (get total-shares property))
                          (get total-area-sqft property))
        })
    )
)
