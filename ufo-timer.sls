(library (ufo-timer)
  (export 
    init-timer
    init-interval-timer
    start-timer)
  (import 
    (chezscheme)
    (ufo-thread-pool))

(define-record-type timer
  (fields 
    (immutable timeout)
    (immutable todo)
    (immutable mutex)
    (immutable condition)
    (immutable thread-pool))
  (protocol
    (lambda (new)
      (lambda (timeout todo thread-pool)
        (new timeout todo (make-mutex) (make-condition) thread-pool)))))

(define init-timer 
  (case-lambda 
    [(timeout todo) (init-timer timeout todo (init-thread-pool 1))]
    [(timeout todo thread-pool) (make-timer timeout todo thread-pool)]))

(define init-interval-timer 
  (case-lambda 
    [(interval todo) (init-interval-timer interval todo (lambda () #t))]
    [(interval todo stop) (init-interval-timer interval todo stop (init-thread-pool 1))]
    [(interval todo stop thread-pool)
      (make-timer 
        interval
        (lambda ()
          (if (stop)
            (begin 
              (todo)
              (start-timer (init-interval-timer interval todo stop thread-pool)))))
        thread-pool)]))

(define (start-timer timer)
  (thread-pool-add-job 
    (timer-thread-pool timer)
    (lambda ()
      (with-mutex (timer-mutex timer)
        (condition-wait (timer-condition timer) (timer-mutex timer) (timer-timeout timer))
        ((timer-todo timer))))))
)