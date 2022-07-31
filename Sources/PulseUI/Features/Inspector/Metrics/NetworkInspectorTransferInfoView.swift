// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import PulseCore

// MARK: - View

struct NetworkInspectorTransferInfoView: View {
    let viewModel: NetworkInspectorTransferInfoViewModel

#if os(watchOS)
    var body: some View {
        HStack(alignment: .center) {
            if viewModel.isUpload {
                bytesSent
            } else {
                bytesReceived
            }
        }
        .padding(.top, 24)
    }
#else
    var body: some View {
        HStack {
            Spacer()
            bytesSent
            Spacer()

            Divider()

            Spacer()
            bytesReceived
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
#endif

    private var bytesSent: some View {
        makeView(
            title: "Sent",
            imageName: "arrow.up.circle",
            total: viewModel.totalBytesSent,
            headers: viewModel.headersBytesSent,
            body: viewModel.bodyBytesSent
        )
    }

    private var bytesReceived: some View {
        makeView(
            title: "Received",
            imageName: "arrow.down.circle",
            total: viewModel.totalBytesReceived,
            headers: viewModel.headersBytesReceived,
            body: viewModel.bodyBytesReceived
        )
    }

    private func makeView(title: String, imageName: String, total: String, headers: String, body: String) -> some View {
        VStack {
            HStack(alignment: .center, spacing: spacing) {
                Image(systemName: imageName)
                    .font(.largeTitle)
                Text(title + "\n" + total)
                    .font(.headline)
                    .fixedSize()
                    .lineSpacing(0)
            }
            .fixedSize()
            .padding(2)
            HStack(alignment: .center, spacing: 4) {
                VStack(alignment: .trailing) {
                    Text("Headers:")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                    Text("Body:")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                VStack(alignment: .leading) {
                    Text(headers)
                        .font(.footnote)
                    Text(body)
                        .font(.footnote)
                }
            }
            .fixedSize()
        }
    }
}

#if os(tvOS)
private let spacing: CGFloat = 20
#else
private let spacing: CGFloat? = nil
#endif

// MARK: - Preview

#if DEBUG
struct NetworkInspectorTransferInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkInspectorTransferInfoView(viewModel: mockModel)
            .padding()
            .fixedSize()
            .previewLayout(.sizeThatFits)
    }
}

private let mockModel = NetworkInspectorTransferInfoViewModel(
    metrics: LoggerStore.preview.entity(for: .login).metrics!, taskType: .dataTask
)

#endif

// MARK: - ViewModel

struct NetworkInspectorTransferInfoViewModel {
    let totalBytesSent: String
    let bodyBytesSent: String
    let headersBytesSent: String

    let totalBytesReceived: String
    let bodyBytesReceived: String
    let headersBytesReceived: String

    let isUpload: Bool

    init(empty: Bool) {
        totalBytesSent = "–"
        bodyBytesSent = "–"
        headersBytesSent = "–"
        totalBytesReceived = "–"
        bodyBytesReceived = "–"
        headersBytesReceived = "–"
        isUpload = false
    }

    init(metrics: NetworkLoggerMetrics, taskType: NetworkLoggerTaskType) {
        self.init(transferSize: metrics.transferSize, isUpload: taskType == .uploadTask)
    }

    init(transferSize: NetworkLoggerMetrics.TransferSize, isUpload: Bool = false) {
        totalBytesSent = formatBytes(transferSize.totalBytesSent)
        bodyBytesSent = formatBytes(transferSize.bodyBytesSent)
        headersBytesSent = formatBytes(transferSize.headersBytesSent)

        totalBytesReceived = formatBytes(transferSize.totalBytesReceived)
        bodyBytesReceived = formatBytes(transferSize.bodyBytesReceived)
        headersBytesReceived = formatBytes(transferSize.headersBytesReceived)

        self.isUpload = isUpload
    }
}

private func formatBytes(_ count: Int64) -> String {
    ByteCountFormatter.string(fromByteCount: max(0, count), countStyle: .file)
}
