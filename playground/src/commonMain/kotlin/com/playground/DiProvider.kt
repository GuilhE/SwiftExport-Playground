package com.playground

object DiProvider {
    fun kotlinImpl(): CoroutinesExport = CoroutinesExportImpl()

    fun tickerControl(ticker: Ticker): TickerControl = TickerControlImpl(ticker)
}
