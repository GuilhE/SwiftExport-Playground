package com.playground

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.cancellable
import kotlinx.coroutines.flow.flow

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
        flow {
            while (true) {
                emit(DataImpl(ticker.onTick(++tick)))
            }
        }.cancellable()
            .collect { data ->
                println("TickerControlImpl > onTick ${data.value}")
                events.value = data
            }
    }

    override fun stop() {
        println("TickerControlImpl > stop")
    }
}
