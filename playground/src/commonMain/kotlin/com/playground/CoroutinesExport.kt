@file:Suppress("unused", "ObjectPropertyName")

package com.playground

import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.milliseconds

class UpsException : Exception("Ups! Something went wrong.")

interface Data {
    val value: String
}

data class DataClass(
    override val value: String,
) : Data

private val _stateFlow = MutableStateFlow(DataClass("Hello!"))

fun observeStateFlow(): StateFlow<Data> = _stateFlow.asStateFlow()

fun updateStateFlow(newValue: String) {
    _stateFlow.value = DataClass(newValue)
}

suspend fun suspendFunction(): DataClass {
    delay(2000.milliseconds)
    return if ((0..1).random() < 0.5) {
        DataClass("Hello from suspend fun")
    } else {
        throw UpsException()
    }
}

fun createFlow(): Flow<DataClass> =
    flow {
        emit(DataClass("Hello!"))
        delay(1000.milliseconds)
        emit(DataClass("SwiftExport"))
        delay(1000.milliseconds)
        emit(DataClass("Coroutines"))
        delay(1000.milliseconds)
        emit(DataClass("Are here!"))
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
