@file:Suppress("unused", "ObjectPropertyName")

package com.playground

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch

data class DataClass(val value: String)

private val _stateFlow = MutableStateFlow(DataClass("Hello!"))
val stateFlow: StateFlow<DataClass> = _stateFlow.asStateFlow()

fun updateStateFlow(newValue: String) {
    _stateFlow.value = DataClass(newValue)
}

suspend fun suspendFunction(): DataClass {
    delay(2000)
    return DataClass("Hello from suspend fun")
}

fun flowCreator(): Flow<DataClass> {
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
fun spawnCancelableCoroutine(callback: (String) -> Unit) {
    cancelCoroutine()
    flowJob = CoroutineScope(Dispatchers.Default).launch(Dispatchers.Main) {
        flowCreator().collect { callback(it.value) }
    }
}

fun cancelCoroutine() {
    flowJob?.cancel()
    flowJob = null
}

fun spawnCoroutine(callback: (String) -> Unit) {
    CoroutineScope(Dispatchers.Default).launch(Dispatchers.Main) {
        flowCreator().collect { callback(it.value) }
    }
}