//
//  Generated file. Do not edit.
//

// clang-format off

import FlutterMacOS
import Foundation

import native_pdf_renderer
import path_provider_macos
import shared_preferences_macos
import sqflite

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  NativePdfRendererPlugin.register(with: registry.registrar(forPlugin: "NativePdfRendererPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
