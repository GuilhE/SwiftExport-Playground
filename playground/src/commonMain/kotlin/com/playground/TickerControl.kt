package com.playground

import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

interface Ticker {
    suspend fun onTick(tick: Int): String
}

interface TickerControl {
    fun observeEvents(): StateFlow<Data>

    suspend fun start()

    fun stop()
}

internal class TickerControlImpl(
    private val ticker: Ticker,
) : TickerControl {
    private val events = MutableStateFlow<Data>(DataImpl("Waiting for Kotlin…"))

    override fun observeEvents(): StateFlow<Data> = events.asStateFlow()

    override suspend fun start() {
        println("TickerControlImpl > start")
        var tick = 0
        while (true) {
            currentCoroutineContext().ensureActive()
            events.update {
                DataImpl(ticker.onTick(++tick)).also {
                    println("TickerControlImpl > onTick ${it.value}")
                }
            }
        }
    }

    override fun stop() {
        println("TickerControlImpl > stop")
    }
}
