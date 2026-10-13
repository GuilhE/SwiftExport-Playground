package com.playground

import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow

interface Ticker {
    suspend fun onTick(tick: Int): String
}

interface TickerControl {
    fun observeEvents(): SharedFlow<Data>

    suspend fun start()

    fun stop()
}

internal class TickerControlImpl(
    private val ticker: Ticker,
) : TickerControl {
    private val events = MutableSharedFlow<Data>(replay = 0, extraBufferCapacity = 1)

    override fun observeEvents(): SharedFlow<Data> = events.asSharedFlow()

    override suspend fun start() {
        var tick = 0
        while (true) {
            currentCoroutineContext().ensureActive()
            events.emit(DataImpl(ticker.onTick(++tick)))
        }
    }

    override fun stop() {
        events.tryEmit(DataImpl("Stopped"))
    }
}
