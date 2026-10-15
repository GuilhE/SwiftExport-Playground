package com.playground

import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.launch
import kotlin.coroutines.cancellation.CancellationException

@Suppress("unused")
object DiProvider {
    fun kotlinImpl(): CoroutinesExport = CoroutinesExportImpl()

    fun tickerControl(ticker: Ticker): TickerControl = TickerControlImpl(ticker)

    suspend fun startTickerControl(control: TickerControl) =
        coroutineScope {
            val job =
                launch {
                    control
                        .observeEvents()
                        .collect { data ->
                            println("Swift TickerControl > collected ${data.value}")
                        }
                }
            job.invokeOnCompletion { cause ->
                if (cause is CancellationException) println("Swift TickerControl > OnCompletion called")
            }
            println("Swift TickerControl > start")
            control.start()
        }
}
