@file:Suppress("unused")

package com.playground

sealed interface DownloadState {
    data object Idle : DownloadState

    data class InProgress(
        val percent: Int,
    ) : DownloadState

    data class Completed(
        val fileName: String,
    ) : DownloadState

    data class Failed(
        val reason: String,
    ) : DownloadState
}

fun idleDownloadState(): DownloadState = DownloadState.Idle

fun nextDownloadState(current: DownloadState): DownloadState =
    when (current) {
        is DownloadState.Idle -> DownloadState.InProgress(percent = 0)
        is DownloadState.InProgress ->
            if (current.percent >= 100) {
                DownloadState.Completed(fileName = "export.zip")
            } else if (current.percent >= 70 && (0..1).random() == 0) {
                DownloadState.Failed(reason = "Connection lost")
            } else {
                DownloadState.InProgress(percent = current.percent + 20)
            }
        is DownloadState.Completed -> DownloadState.Idle
        is DownloadState.Failed -> DownloadState.Idle
    }
