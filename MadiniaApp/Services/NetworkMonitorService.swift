//
//  NetworkMonitorService.swift
//  MadiniaApp
//
//  Service de surveillance de la connectivité réseau en temps réel.
//

import Foundation
import Network

/// Type de connexion réseau
enum ConnectionType: String {
    case wifi = "Wi-Fi"
    case cellular = "Cellulaire"
    case wiredEthernet = "Ethernet"
    case unknown = "Inconnu"
}

/// Service de surveillance de la connectivité réseau en temps réel via NWPathMonitor.
@Observable
final class NetworkMonitorService {

    // MARK: - Singleton

    static let shared = NetworkMonitorService()

    // MARK: - Published Properties

    /// Indique si l'appareil est actuellement connecté à internet
    private(set) var isConnected: Bool = true

    /// Type de connexion actuelle (wifi, cellular, etc.)
    private(set) var connectionType: ConnectionType = .unknown

    /// Indique si la connexion est coûteuse (données cellulaires, hotspot)
    private(set) var isExpensive: Bool = false

    /// Indique si la connexion est contrainte (mode données réduites)
    private(set) var isConstrained: Bool = false

    // MARK: - Callbacks

    /// Callback appelé lors d'un changement de connectivité
    var onConnectivityChange: ((Bool) -> Void)?

    /// Callback appelé lors du retour en ligne
    var onBackOnline: (() -> Void)?

    // MARK: - Private Properties

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.madinia.networkmonitor", qos: .utility)
    private var wasConnected: Bool = true

    // MARK: - Initialization

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    /// Démarre la surveillance du réseau
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            DispatchQueue.main.async {
                let previouslyConnected = self.isConnected

                self.isConnected = path.status == .satisfied
                self.isExpensive = path.isExpensive
                self.isConstrained = path.isConstrained
                self.connectionType = self.determineConnectionType(from: path)

                // Notifier du changement
                self.onConnectivityChange?(self.isConnected)

                // Détecter le retour en ligne
                if !previouslyConnected && self.isConnected {
                    self.onBackOnline?()
                }

                self.wasConnected = self.isConnected

                #if DEBUG
                print("[NetworkMonitor] Status: \(self.isConnected ? "Connected" : "Disconnected"), Type: \(self.connectionType.rawValue), Expensive: \(self.isExpensive)")
                #endif
            }
        }

        monitor.start(queue: queue)
    }

    /// Arrête la surveillance du réseau
    func stopMonitoring() {
        monitor.cancel()
    }

    /// Vérifie si le téléchargement est recommandé (WiFi ou non-coûteux)
    var isDownloadRecommended: Bool {
        return isConnected && !isExpensive
    }

    // MARK: - Private Methods

    private func determineConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        } else {
            return .unknown
        }
    }
}
