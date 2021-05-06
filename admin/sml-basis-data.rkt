#lang racket

;; Copyright 2021 Lassi Kortela
;; SPDX-License-Identifier: ISC

(define sml-basis-data-base-url "https://smlfamily.github.io/Basis/")

(define sml-basis-data-exceptions '())
(define sml-basis-data-functors '())
(define sml-basis-data-signatures '())
(define sml-basis-data-structures '())
(define sml-basis-data-types '())
(define sml-basis-data-values '())

(define-syntax-rule (add-to var where url)
  (set! var (append var (list (cons where url)))))

(define (split-and-keep-delimiters char s)
  (let ((n (string-length s)))
    (let loop ((fields '()) (a 0) (b 0))
      (cond ((= a b n)
             (reverse fields))
            ((= b n)
             (loop (cons (substring s a b) fields) b b))
            ((char=? char (string-ref s b))
             (loop (list* (substring s b (+ b 1))
                          (substring s a b)
                          fields)
                   (+ b 1)
                   (+ b 1)))
            (else
             (loop fields a (+ b 1)))))))

(define (split-url url)
  (set! url (string-replace url "\\|@GT\\|"  ">"))
  (set! url (string-replace url "\\|@GTE\\|" ">="))
  (set! url (string-replace url "\\|@LT\\|"  "<"))
  (set! url (string-replace url "\\|@LTE\\|" "<="))
  (let ((halves (string-split url "#" #:trim? #f #:repeat? #f)))
    (if (= 2 (length halves))
        (split-and-keep-delimiters #\: (list-ref halves 1))
        (error "Bad URL:" url))))

(define (input-url url)
  (match (split-url url)
    ((list "SIG" ":" where ":" "=" ":" "VAL" ":" "SPEC")  ; hack for ":="
     (add-to sml-basis-data-values where url))
    ((list "SIG" ":" where ":" "VAL" ":" "SPEC")
     (add-to sml-basis-data-values where url))
    ((list "SIG" ":" where ":" "STR" ":" "SPEC")
     (add-to sml-basis-data-structures where url))
    ((list "SIG" ":" where ":" "EXN" ":" "SPEC")
     (add-to sml-basis-data-exceptions where url))
    ((list "SIG" ":" where ":" "TY"  ":" "SPEC")
     (add-to sml-basis-data-types where url))
    ((list "ARG" ":" where ":" "STR" ":" "SPEC")
     (add-to sml-basis-data-structures where url))
    ((list "ARG" ":" where ":" "VAL" ":" "SPEC")
     (add-to sml-basis-data-values where url))
    ((list "ARG" ":" where ":" "TY"  ":" "SPEC")
     (add-to sml-basis-data-types where url))
    ((list where ":" "FCT" ":" "SPEC")
     (add-to sml-basis-data-functors where url))
    ((list where ":" "SIG" ":" "SPEC")
     (add-to sml-basis-data-signatures where url))
    ((list where ":" "STR" ":" "SPEC")
     (add-to sml-basis-data-structures where url))
    (else
     (error "This kind of URL is not known to me:" url))))

(define (input)
  (let loop ()
    (let ((url (read-line)))
      (unless (eof-object? url)
        (input-url url)
        (loop)))))

(define-syntax-rule (output-index index)
  (begin (newline)
         (display "(defconst ")
         (display 'index)
         (let ((prefix "  '("))
           (for-each (lambda (item)
                       (newline)
                       (display prefix)
                       (set! prefix "    ")
                       (display "(")
                       (write (car item))
                       (displayln " .")
                       (display prefix)
                       (display " ")
                       (write (cdr item))
                       (display ")"))
                     index))
         (displayln "))")))

(define (output)
  (display ";;; sml-basis-data.el --- Standard ML Basis Library data ")
  (displayln "-*- lexical-binding: t -*-")
  (newline)
  (displayln ";; Copyright 2004 AT&T and Lucent Technologies")
  (newline)
  (display ";; URL: ")
  (displayln sml-basis-data-base-url)
  (newline)
  (displayln ";;; Commentary:")
  (newline)
  (displayln ";; Automatically converted from the web.")
  (newline)
  (displayln ";;; Code:")
  (newline)
  (display "(defconst sml-basis-data-base-url ")
  (write sml-basis-data-base-url)
  (displayln ")")
  (output-index sml-basis-data-exceptions)
  (output-index sml-basis-data-functors)
  (output-index sml-basis-data-signatures)
  (output-index sml-basis-data-structures)
  (output-index sml-basis-data-types)
  (output-index sml-basis-data-values)
  (newline)
  (displayln "(provide 'sml-basis-data)")
  (newline)
  (displayln ";;; sml-basis-data.el ends here"))

(input)
(output)