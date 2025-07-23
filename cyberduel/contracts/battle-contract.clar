;; Cyber Hack Battle - Futuristic Digital Combat Arena
;; Two hackers deploy cyber weapons in encrypted commits, then decrypt to determine winner

;; Constants
(define-constant SYSTEM-ADMIN tx-sender)
(define-constant ERR-ACCESS-DENIED (err u100))
(define-constant ERR-SESSION-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-DEPLOYED (err u102))
(define-constant ERR-NOT-DEPLOYED (err u103))
(define-constant ERR-ALREADY-DECRYPTED (err u104))
(define-constant ERR-INVALID-WEAPON (err u105))
(define-constant ERR-BATTLE-TERMINATED (err u106))
(define-constant ERR-DECRYPT-TOO-EARLY (err u107))
(define-constant ERR-UNAUTHORIZED-HACKER (err u108))

;; Cyber weapon constants
(define-constant VIRUS u1)      ;; Defeats Firewall
(define-constant FIREWALL u2)   ;; Defeats DDoS
(define-constant DDOS u3)       ;; Defeats Virus

;; Battle states
(define-constant STATE-DEPLOYING-WEAPONS u0)
(define-constant STATE-DECRYPTING-CODE u1)
(define-constant STATE-BATTLE-COMPLETE u2)

;; Data structures
(define-map hack-battles
  { session-id: uint }
  {
    hacker1: principal,
    hacker2: principal,
    hacker1-encrypted-weapon: (buff 32),
    hacker2-encrypted-weapon: (buff 32),
    hacker1-weapon: (optional uint),
    hacker2-weapon: (optional uint),
    winner: (optional principal),
    state: uint,
    session-start: uint,
    server-ip: (string-ascii 15)
  }
)

(define-data-var next-session-id uint u1)

;; Initialize hack battle session
(define-public (init-hack-battle (target-hacker principal) (server-target (string-ascii 15)))
  (let ((session-id (var-get next-session-id)))
    (asserts! (not (is-eq tx-sender target-hacker)) ERR-ACCESS-DENIED)
    (map-set hack-battles
      { session-id: session-id }
      {
        hacker1: tx-sender,
        hacker2: target-hacker,
        hacker1-encrypted-weapon: 0x,
        hacker2-encrypted-weapon: 0x,
        hacker1-weapon: none,
        hacker2-weapon: none,
        winner: none,
        state: STATE-DEPLOYING-WEAPONS,
        session-start: block-height,
        server-ip: server-target
      }
    )
    (var-set next-session-id (+ session-id u1))
    (ok session-id)
  )
)

;; Deploy encrypted cyber weapon
(define-public (deploy-weapon (session-id uint) (encrypted-payload (buff 32)))
  (let ((battle (unwrap! (map-get? hack-battles { session-id: session-id }) ERR-SESSION-NOT-FOUND)))
    (asserts! (is-eq (get state battle) STATE-DEPLOYING-WEAPONS) ERR-BATTLE-TERMINATED)
    (asserts! (> (len encrypted-payload) u0) ERR-INVALID-WEAPON)
    
    (if (is-eq tx-sender (get hacker1 battle))
      (begin
        (asserts! (is-eq (len (get hacker1-encrypted-weapon battle)) u0) ERR-ALREADY-DEPLOYED)
        (map-set hack-battles
          { session-id: session-id }
          (merge battle { hacker1-encrypted-weapon: encrypted-payload })
        )
        (check-both-weapons-deployed session-id)
      )
      (if (is-eq tx-sender (get hacker2 battle))
        (begin
          (asserts! (is-eq (len (get hacker2-encrypted-weapon battle)) u0) ERR-ALREADY-DEPLOYED)
          (map-set hack-battles
            { session-id: session-id }
            (merge battle { hacker2-encrypted-weapon: encrypted-payload })
          )
          (check-both-weapons-deployed session-id)
        )
        ERR-UNAUTHORIZED-HACKER
      )
    )
  )
)

;; Check if both weapons are deployed
(define-private (check-both-weapons-deployed (session-id uint))
  (let ((battle (unwrap! (map-get? hack-battles { session-id: session-id }) ERR-SESSION-NOT-FOUND)))
    (if (and 
          (> (len (get hacker1-encrypted-weapon battle)) u0)
          (> (len (get hacker2-encrypted-weapon battle)) u0))
      (begin
        (map-set hack-battles
          { session-id: session-id }
          (merge battle { state: STATE-DECRYPTING-CODE })
        )
        (ok true)
      )
      (ok false)
    )
  )
)

;; Decrypt and reveal cyber weapon
(define-public (decrypt-weapon (session-id uint) (weapon uint) (encryption-key uint))
  (let ((battle (unwrap! (map-get? hack-battles { session-id: session-id }) ERR-SESSION-NOT-FOUND)))
    (asserts! (is-eq (get state battle) STATE-DECRYPTING-CODE) ERR-DECRYPT-TOO-EARLY)
    (asserts! (or (is-eq weapon VIRUS) (is-eq weapon FIREWALL) (is-eq weapon DDOS)) ERR-INVALID-WEAPON)
    
    (let ((weapon-hash (sha256 (concat (concat (unwrap-panic (to-consensus-buff? weapon)) 
                                              (unwrap-panic (to-consensus-buff? encryption-key))) 
                                      (unwrap-panic (to-consensus-buff? tx-sender))))))
      (if (is-eq tx-sender (get hacker1 battle))
        (begin
          (asserts! (is-eq weapon-hash (get hacker1-encrypted-weapon battle)) ERR-INVALID-WEAPON)
          (asserts! (is-none (get hacker1-weapon battle)) ERR-ALREADY-DECRYPTED)
          (map-set hack-battles
            { session-id: session-id }
            (merge battle { hacker1-weapon: (some weapon) })
          )
          (execute-cyber-attack session-id)
        )
        (if (is-eq tx-sender (get hacker2 battle))
          (begin
            (asserts! (is-eq weapon-hash (get hacker2-encrypted-weapon battle)) ERR-INVALID-WEAPON)
            (asserts! (is-none (get hacker2-weapon battle)) ERR-ALREADY-DECRYPTED)
            (map-set hack-battles
              { session-id: session-id }
              (merge battle { hacker2-weapon: (some weapon) })
            )
            (execute-cyber-attack session-id)
          )
          ERR-UNAUTHORIZED-HACKER
        )
      )
    )
  )
)

;; Execute the cyber attack and determine winner
(define-private (execute-cyber-attack (session-id uint))
  (let ((battle (unwrap! (map-get? hack-battles { session-id: session-id }) ERR-SESSION-NOT-FOUND)))
    (match (get hacker1-weapon battle)
      weapon1
      (match (get hacker2-weapon battle)
        weapon2
        (let ((winner (resolve-cyber-battle weapon1 weapon2 (get hacker1 battle) (get hacker2 battle))))
          (map-set hack-battles
            { session-id: session-id }
            (merge battle { winner: winner, state: STATE-BATTLE-COMPLETE })
          )
          (ok winner)
        )
        (ok none)
      )
      (ok none)
    )
  )
)

;; Resolve cyber battle: Virus > Firewall > DDoS > Virus
(define-private (resolve-cyber-battle (weapon1 uint) (weapon2 uint) (hacker1 principal) (hacker2 principal))
  (if (is-eq weapon1 weapon2)
    none ;; System deadlock
    (if (or 
          (and (is-eq weapon1 VIRUS) (is-eq weapon2 FIREWALL))
          (and (is-eq weapon1 FIREWALL) (is-eq weapon2 DDOS))
          (and (is-eq weapon1 DDOS) (is-eq weapon2 VIRUS)))
      (some hacker1)
      (some hacker2)
    )
  )
)

;; Read-only functions
(define-read-only (get-battle-status (session-id uint))
  (map-get? hack-battles { session-id: session-id })
)

(define-read-only (get-battle-winner (session-id uint))
  (match (map-get? hack-battles { session-id: session-id })
    battle (ok (get winner battle))
    ERR-SESSION-NOT-FOUND
  )
)

(define-read-only (weapon-name (weapon-code uint))
  (if (is-eq weapon-code VIRUS)
    "Virus"
    (if (is-eq weapon-code FIREWALL)
      "Firewall"
      (if (is-eq weapon-code DDOS)
        "DDoS Attack"
        "Unknown Weapon"
      )
    )
  )
)

(define-read-only (get-server-target (session-id uint))
  (match (map-get? hack-battles { session-id: session-id })
    battle (ok (get server-ip battle))
    ERR-SESSION-NOT-FOUND
  )
)