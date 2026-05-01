import SwiftUI

/// Fake Android Studio IDE app view
struct AndroidStudioAppView: View {
    let windowState: WindowState
    private let theme = AndroidStudioTheme()

    @State private var fileNodes = Self.sampleFileTree()
    @State private var selectedFileId: UUID?
    @State private var selectedTabIndex = 0
    @State private var codeText = Self.mainActivityCode
    @State private var tabs: [IDETab] = [
        IDETab(title: "MainActivity.kt", icon: "k.circle", iconColor: .purple),
    ]

    var body: some View {
        IDELayoutView(theme: theme) {
            AndroidStudioToolbar(theme: theme, onRun: {
                // Logcat is static — toolbar just shows build animation
            })
        } sidebar: {
            FileTreeView(
                theme: theme, nodes: $fileNodes,
                selectedFileId: $selectedFileId,
                onFileSelect: { node in openFile(node) }
            )
        } editor: {
            VStack(spacing: 0) {
                IDETabBarView(
                    theme: theme, tabs: tabs,
                    selectedIndex: $selectedTabIndex,
                    onClose: { i in
                        if tabs.count > 1 {
                            tabs.remove(at: i)
                            selectedTabIndex = min(selectedTabIndex, tabs.count - 1)
                        }
                    }
                )
                theme.separatorColor.frame(height: 1)
                CodeEditorView(theme: theme, language: .kotlin, text: $codeText)
            }
        } bottomPanel: {
            AndroidStudioLogcat(theme: theme)
        }
        .onAppear {
            windowState.title = "MyApp — Android Studio"
        }
    }

    private func openFile(_ node: FileNode) {
        if let content = node.content { codeText = content }
        if !tabs.contains(where: { $0.title == node.name }) {
            let iconColor: Color = node.name.hasSuffix(".kt") ? .purple :
                node.name.hasSuffix(".xml") ? .orange : .gray
            tabs.append(IDETab(title: node.name, icon: "doc", iconColor: iconColor))
        }
        if let index = tabs.firstIndex(where: { $0.title == node.name }) {
            selectedTabIndex = index
        }
        windowState.title = "MyApp — \(node.name) — Android Studio"
    }
}

// MARK: - Sample Data
extension AndroidStudioAppView {
    static func sampleFileTree() -> [FileNode] {
        [FileNode(
            name: "MyApp", icon: "folder.fill", iconColor: Color(red: 0.2, green: 0.7, blue: 0.3),
            isFolder: true, children: [
                FileNode(name: "app", icon: "folder.fill", iconColor: .yellow, isFolder: true, children: [
                    FileNode(name: "manifests", icon: "folder.fill", iconColor: .yellow, isFolder: true, children: [
                        FileNode(name: "AndroidManifest.xml", icon: "doc", iconColor: .orange, language: .xml),
                    ]),
                    FileNode(name: "java", icon: "folder.fill", iconColor: .blue, isFolder: true, children: [
                        FileNode(name: "com.example.myapp", icon: "folder.fill", iconColor: .gray, isFolder: true, children: [
                            FileNode(name: "MainActivity.kt", icon: "k.circle", iconColor: .purple,
                                     language: .kotlin, content: mainActivityCode),
                            FileNode(name: "MainViewModel.kt", icon: "k.circle", iconColor: .purple,
                                     language: .kotlin, content: viewModelCode),
                            FileNode(name: "ui", icon: "folder.fill", iconColor: .yellow, isFolder: true, children: [
                                FileNode(name: "HomeScreen.kt", icon: "k.circle", iconColor: .purple,
                                         language: .kotlin, content: homeScreenCode),
                                FileNode(name: "theme", icon: "folder.fill", iconColor: .yellow, isFolder: true, children: [
                                    FileNode(name: "Theme.kt", icon: "k.circle", iconColor: .purple, language: .kotlin),
                                ]),
                            ]),
                        ], isExpanded: true),
                    ], isExpanded: true),
                    FileNode(name: "res", icon: "folder.fill", iconColor: .green, isFolder: true, children: [
                        FileNode(name: "layout", icon: "folder.fill", iconColor: .yellow, isFolder: true),
                        FileNode(name: "values", icon: "folder.fill", iconColor: .yellow, isFolder: true),
                    ]),
                    FileNode(name: "build.gradle.kts", icon: "doc", iconColor: .green, language: .kotlin),
                ], isExpanded: true),
                FileNode(name: "gradle", icon: "folder.fill", iconColor: .gray, isFolder: true, children: [
                    FileNode(name: "libs.versions.toml", icon: "doc", iconColor: .gray),
                ]),
                FileNode(name: "settings.gradle.kts", icon: "doc", iconColor: .green, language: .kotlin),
            ], isExpanded: true
        )]
    }

    static let mainActivityCode = """
package com.example.myapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import com.example.myapp.ui.theme.MyAppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyAppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    HomeScreen()
                }
            }
        }
    }
}
"""

    static let viewModelCode = """
package com.example.myapp

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class UiState(
    val count: Int = 0,
    val isLoading: Boolean = false
)

class MainViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(UiState())
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    fun increment() {
        _uiState.value = _uiState.value.copy(
            count = _uiState.value.count + 1
        )
    }
}
"""

    static let homeScreenCode = """
package com.example.myapp.ui

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.myapp.MainViewModel

@Composable
fun HomeScreen(viewModel: MainViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Count: ${uiState.count}",
            style = MaterialTheme.typography.headlineMedium
        )
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { viewModel.increment() }) {
            Text("Increment")
        }
    }
}
"""
}
