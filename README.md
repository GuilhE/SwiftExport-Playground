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
- **A `suspend` loop driven by the caller's `Task` needs its own cancellation checkpoint.** Cancelling the Swift `Task` running
  `TickerControl.start()` doesn't stop the Kotlin loop by itself — without an explicit `ensureActive()` each iteration, it turns into a busy
  loop pegging a CPU core forever. Verified in `CancellationCheckpointTests`.

## Validating these claims

`iosApp/iosAppTests/` (target `SwiftExportValidationTests`) has a runnable XCTest for the claim above. Run it with:

```
xcodebuild test -project iosApp/SwiftExport.xcodeproj -scheme SwiftExportValidationTests -destination 'platform=iOS Simulator,name=iPhone 17'
```
