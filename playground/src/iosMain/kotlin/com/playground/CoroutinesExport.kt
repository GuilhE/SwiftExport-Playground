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

private val _stateFlow = MutableStateFlow("Hello!")
val stateFlow: StateFlow<String> = _stateFlow.asStateFlow()

fun updateStateFlow(newValue: String) {
    _stateFlow.value = newValue
}

suspend fun suspendFunction(): String {
    delay(2000)
    return "Hello from suspend fun"
}

fun suspendFlowFunction(): Flow<String> {
    return flow {
        emit("Hello!")
        delay(1000)
        emit("SwiftExport")
        delay(1000)
        emit("Coroutines")
        delay(1000)
        emit("Are here!")
    }
}

private var flowJob: Job? = null
fun suspendFlowFunction(callback: (String) -> Unit) {
    cancelSuspendFlowFunction()
    flowJob = CoroutineScope(Dispatchers.Default).launch(Dispatchers.Main) {
        suspendFlowFunction().collect { value ->
            callback(value)
        }
    }
}

fun cancelSuspendFlowFunction() {
    flowJob?.cancel()
    flowJob = null
}

fun suspendFlowFunctionSpawn(callback: (String) -> Unit) {
    CoroutineScope(Dispatchers.Default).launch(Dispatchers.Main) {
        suspendFlowFunction().collect { value ->
            callback(value)
        }
    }
}