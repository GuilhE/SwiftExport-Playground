@file:Suppress("unused", "ObjectPropertyName")

package com.playground

import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch

class UpsException : Exception("Ups! Something went wrong.")

data class DataClass(val value: String)

private val _stateFlow = MutableStateFlow(DataClass("Hello!"))

fun observeStateFlow(): Flow<DataClass> = _stateFlow.asStateFlow()

fun updateStateFlow(newValue: String) {
    println("🔄 updateStateFlow() called with value: $newValue")
    _stateFlow.value = DataClass(newValue)
    println("✓ StateFlow updated")
}

suspend fun suspendFunction(): DataClass {
    delay(2000)
    return if ((0..1).random() < 0.5) {
        DataClass("Hello from suspend fun")
    } else {
        throw UpsException()
    }
}

fun createFlow(): Flow<DataClass> {
    return flow {
        emit(DataClass("Hello!"))
        delay(1000)
        emit(DataClass("SwiftExport"))
        delay(1000)
        emit(DataClass("Coroutines"))
        delay(1000)
        emit(DataClass("Are here!"))
    }
}

private var flowJob: Job? = null
fun createCancelableFlow(): Flow<DataClass> {
    cancelFlow()
    return channelFlow { flowJob = launch { createFlow().collect { value -> send(value) } } }
}

fun cancelFlow() {
    flowJob?.cancel()
    flowJob = null
}