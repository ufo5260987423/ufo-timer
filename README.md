# ufo-timer

Implementing timer requires thread mechanism, and this feature is not always supported in scheme. All I now know is [SRFI-120](https://srfi.schemers.org/srfi-120/) provide timer based on [SRFI-18](https://srfi.schemers.org/srfi-18/), which is an implementation of POSIX thread model.  However, [SRFI-18](https://srfi.schemers.org/srfi-18/) released on 2001. Although [Chez Scheme](https://cisco.github.io/ChezScheme/) also implements POSIX thread, it opened source much latter, and never claims to be consistent with [SRFI-18](https://srfi.schemers.org/srfi-18/). This makes [SRFI-120](https://srfi.schemers.org/srfi-120/) not portable to [Chez Scheme](https://cisco.github.io/ChezScheme/).

This repository is a timer implementation based on Chez Scheme's thread mechanism. And before importing this repository, please firstly `(import (chezscheme))`.

## Prerequire
[Chez Scheme](https://cisco.github.io/ChezScheme/) and [AKKU](https://akkuscm.org/). In addition, though [Chez Scheme](https://cisco.github.io/ChezScheme/) claims its thread mechanism portable to Windows, I've not done any tests on this point.

## Example
`(import (ufo-timer))` to use timer.  

### Print "test" after 5 seconds,

```lisp 
(let ([timer 
        (init-timer 
            (make-time 'time-duration 0 5) 
            (lambda () (pretty-print 'test)))])
    (start-timer timer))
```
>NOTE: (make-time 'time-duration 0 5) is to make Chez Scheme's time object.

### Repeat "test" with 5-seconds interval

```lisp 
(let ([timer 
        (init-interval-timer 
            (make-time 'time-duration 0 5) 
            (lambda () (pretty-print 'test)))])
    (start-timer timer))
```

## Advanced features 

### Thread pool
This repository is based on [ufo-thread-pool](https://github.com/ufo5260987423/ufo-thread-pool), and users can also assign a pool to timers like following:

1. `(init-timer timeout todo pool)`
2. `(init-interval-timer timeout todo stop pool)`

>NOTE: you need to additionally `(import (ufo-thread-pool))`.

For more related description, please refer to other cases in this text.

### Stop interval timer 
As shown above, interval timer have a `stop` parameter which is default `(lambda () #t)` and such interval timer will never stop. If you want it to react to some condition, such as stopping when reach 3 times, following closure will help a lot:
```lisp
(let* ([i 0]
        [timer 
        (init-interval-timer 
            (make-time 'time-duration 0 5) 
            (lambda () 
                (set! i (+ 1 i))
                (pretty-print 'test))
            (lambda () (< i 3)))])
    (start-timer timer))
```

### Set expire time
When users do some socket programming, it's very often to set expire time. Or in other words, if a socket is inactive for server seconds, it will be closed by a timer.

```lisp 
(let ([timer 
        (init-interval-timer 
            (make-time 'time-duration 0 5) 
            (lambda () (pretty-print 'try-to-close-socket)))])
    (start-timer timer)
    (with-mutex (timer-mutex timer)
        ;Here's usually a loop body
        ;during the body, you can reset the timer to initial state by following
        (condition-broadcast (timer-condition timer))))
```