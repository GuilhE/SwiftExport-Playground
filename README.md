# SwiftExport playground

<img width="275" src="https://github.com/user-attachments/assets/3be4678c-4354-47cb-aa8c-b0d1cb3b6ed8" />
<img width="275" src="https://github.com/user-attachments/assets/e6d7e666-08a7-4ee7-a8fe-5a1984147a71" />
<img width="275" src="https://github.com/user-attachments/assets/ab8431e8-695b-409a-8a76-0dd80a173439" />


## What's here

- **Coroutines** — Kotlin implements `CoroutinesExport` (`StateFlow`, cold `Flow`, a cancellable `Flow`, a `suspend fun`), Swift consumes it with `async`/`await` and `AsyncSequence` (`asAsyncSequence()`). Standard direction: Kotlin owns the logic, Swift just calls it.
- **Sealed classes** — a Kotlin sealed interface (`DownloadState`) mapped to a Swift enum on the iOS side.
- **Cross inheritance** — Swift implements a minimal Kotlin interface (`Ticker.onTick`, cross-language inheritance) that Kotlin's `TickerControl`
  calls in a loop; the pacing between calls is genuine Swift concurrency (`Task.sleep`). iOS controls the loop's lifecycle (start/cancel) while Kotlin owns the resulting
  `StateFlow<Data>`, exposed via `observeEvents()`.
- **Reverse cross inheritance** — the mirror of the section above: Swift authors *both* `Ticker` and `TickerControl` end-to-end, including a
  hand-rolled `StateFlow<Data>` (cross-inherited `collect`/`value`/`replayCache`, backed by a lock-protected multicast hub with one
  `AsyncStream` per subscriber). Kotlin's only involvement is a top-level `driveTickerControl(control:)` function that calls `start()` and
  collects `observeEvents()`. Note: like a real `StateFlow`, this hand-rolled one always replays the current value to a new subscriber
  before any live updates.

## Limitations

- **Cross-language inheritance needs Kotlin 2.5.0-Beta2+.** Earlier versions either crash at runtime (2.5.0-Beta1) or need an empty `open
  class` workaround to subclass instead of `KotlinBase` directly (2.4.x).
- **No generics across the boundary.** A generic Kotlin function (e.g. `MutableStateFlow<T>(value)`) isn't callable from Swift — you need a
  monomorphic wrapper per concrete type.
