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

interface Data {
    val value: String
}

interface CoroutinesExport {
    fun observeStateFlow(): StateFlow<Data>

    fun updateStateFlow(newValue: String)

    suspend fun suspendFunction(): Data

    fun createFlow(): Flow<Data>

    fun createCancelableFlow(): Flow<Data>

    fun cancelFlow()
}

class UpsException : Exception("Ups! Something went wrong.")

internal data class DataImpl(
    override val value: String,
) : Data

internal class CoroutinesExportImpl : CoroutinesExport {
    private val _stateFlow = MutableStateFlow<Data>(DataImpl("Hello from Kotlin!"))
    private var flowJob: Job? = null

    override fun observeStateFlow(): StateFlow<Data> = _stateFlow.asStateFlow()

    override fun updateStateFlow(newValue: String) {
        _stateFlow.value = DataImpl(newValue)
    }

    override suspend fun suspendFunction(): Data {
        delay(2000.milliseconds)
        return if ((0..1).random() < 0.5) {
            DataImpl("Hello from Kotlin's suspend fun")
        } else {
            throw UpsException()
        }
    }

    override fun createFlow(): Flow<Data> =
        flow {
            emit(DataImpl("Hello!"))
            delay(1000.milliseconds)
            emit(DataImpl("SwiftExport"))
            delay(1000.milliseconds)
            emit(DataImpl("Interface-based"))
            delay(1000.milliseconds)
            emit(DataImpl("Flows are here!"))
        }

    override fun createCancelableFlow(): Flow<Data> {
        cancelFlow()
        return channelFlow { flowJob = launch { createFlow().collect { value -> send(value) } } }
    }

    override fun cancelFlow() {
        flowJob?.cancel()
        flowJob = null
    }
}
