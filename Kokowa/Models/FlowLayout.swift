//
//  FlowLayout.swift
//  Kokowa
//
//  Created by Codex on 2026/07/01.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    /// 子Viewを横に並べ、幅が足りない時は次の行へ折り返したサイズを返す。
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = arrangedRows(maxWidth: maxWidth, subviews: subviews)
        let width = rows.map(\.width).max() ?? 0
        let height = rows.reduce(0) { partialHeight, row in
            partialHeight + row.height
        } + CGFloat(max(rows.count - 1, 0)) * spacing

        return CGSize(width: width, height: height)
    }

    /// 子Viewを折り返しながら配置する。
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangedRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for item in row.items {
                item.subview.place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + spacing
            }

            y += row.height + spacing
        }
    }

    /// 幅に応じて子Viewを行ごとにまとめる。
    private func arrangedRows(maxWidth: CGFloat, subviews: Subviews) -> [FlowLayoutRow] {
        var rows: [FlowLayoutRow] = []
        var currentItems: [FlowLayoutItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let additionalWidth = currentItems.isEmpty ? size.width : size.width + spacing

            if currentItems.isEmpty == false, currentWidth + additionalWidth > maxWidth {
                rows.append(FlowLayoutRow(items: currentItems, width: currentWidth, height: currentHeight))
                currentItems = []
                currentWidth = 0
                currentHeight = 0
            }

            currentItems.append(FlowLayoutItem(subview: subview, size: size))
            currentWidth += currentItems.count == 1 ? size.width : size.width + spacing
            currentHeight = max(currentHeight, size.height)
        }

        if currentItems.isEmpty == false {
            rows.append(FlowLayoutRow(items: currentItems, width: currentWidth, height: currentHeight))
        }

        return rows
    }
}

private struct FlowLayoutRow {
    let items: [FlowLayoutItem]
    let width: CGFloat
    let height: CGFloat
}

private struct FlowLayoutItem {
    let subview: LayoutSubview
    let size: CGSize
}
