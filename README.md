# SwiftExport playground

https://github.com/user-attachments/assets/0abd5a2e-d795-4b0a-b204-8e8aa9f29e96

## What's here

- **Coroutines** — Kotlin implements `CoroutinesExport` (`StateFlow`, cold `Flow`, a cancellable `Flow`, a `suspend fun`), Swift consumes it with `async`/`await` and `AsyncSequence` (`asAsyncSequence()`). Standard direction: Kotlin owns the logic, Swift just calls it.
- **Sealed classes** — a Kotlin sealed interface (`DownloadState`) mapped to a Swift enum on the iOS side.
- **Cross inheritance** — Swift implements a minimal Kotlin interface (`Ticker.onTick`, cross-language inheritance) that Kotlin's `TickerControl`
  calls in a loop; the pacing between calls is genuine Swift concurrency (`Task.sleep`). iOS controls the loop's lifecycle (start/cancel) while Kotlin owns the resulting
  `StateFlow<Data>`, exposed via `observeEvents()`.

## Limitations

- **Cross-language inheritance needs Kotlin 2.5.0-Beta2+.** Earlier versions either crash at runtime (2.5.0-Beta1) or need an empty `open
  class` workaround to subclass instead of `KotlinBase` directly (2.4.x).
- **No generics across the boundary.** A generic Kotlin function (e.g. `MutableStateFlow<T>(value)`) isn't callable from Swift — you need a
  monomorphic wrapper per concrete type.
- **Swift can't author a Kotlin `Flow`.** No way to pass a `suspend` closure as a parameter, so Swift can only forward/wrap a `Flow` Kotlin
  already owns, not build one from scratch. That's why `Ticker.onTick` returns a plain `String` instead of exposing a `Flow`.
- **A `suspend` loop driven by the caller's `Task` needs its own cancellation checkpoint.** Cancelling the Swift `Task` running
  `TickerControl.start()` doesn't stop the Kotlin loop by itself — without an explicit `ensureActive()` each iteration, it turned into a busy
  loop pegging a CPU core forever.
- **Mixing a one-shot signal into an observed `Flow` is a live race.** `TickerControl.stop()` writes `"Stopped"` into the same `Flow` the
  ticks use; a tick already in flight can complete after and overwrite it, non-deterministically. Known, left as-is.
- **`SharedFlow` doesn't survive repeated Swift `Task` cancel/restart cycles — `StateFlow` does.** Swapping `observeEvents()` to
  `MutableSharedFlow(replay = 0)` stops new subscribers from getting the last value, but re-collecting it via `asAsyncSequence()` after the
  first start/stop cycle silently delivers nothing from then on. `StateFlow` doesn't have this problem.
