//
//  GraphView.swift
//  MyTo
//
//  Created by MacBook Pro on 07/06/22.
//

import SwiftUI

struct GraphView: View {
    
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    private let lineColor: Color
    private let startingDate: Date
    private let endingDate: Date
    @State private var percentage: CGFloat = 0
    
    init(coin: CoinModel){
        data = coin.sparklineIn7D?.price ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
        
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        //lineColor = priceChange > 0 ? Color.green : Color.red
        lineColor = Color.blue
        
        endingDate = Date(coinGeckoString: coin.lastUpdated ?? "")
        startingDate = endingDate.addingTimeInterval(-7*24*60*60)
    }
    
    var body: some View {
        VStack{
            graphView
                .frame(height: 200)
                .background(graphBackground)
                .overlay(
                    graphYAxis, alignment: .leading
                )
            graphDateLabel
                .padding(.horizontal, 6)
            
        }
        .font(.caption)
        .foregroundColor(Color.gray)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            withAnimation(.linear(duration: 2.0)){
                percentage = 1.0
            }
            }}
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(coin: dev.coin)
    }
}

extension GraphView{
    
    private var graphView: some View{
        GeometryReader{ geometry in
            Path{ path in
                for index in data.indices{
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    
                    let yAxis = maxY-minY
                    
                    let yPosition = (1 - CGFloat((data[index] - minY) / yAxis)) * geometry.size.height
                    
                    if index == 0{
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .shadow(color: lineColor, radius: 10, x:0, y:10)
            .shadow(color: lineColor.opacity(0.5), radius: 10, x:0, y:20)
            .shadow(color: lineColor.opacity(0.5), radius: 10, x:0, y:30)
            .shadow(color: lineColor.opacity(0.5), radius: 10, x:0, y:40)
        }
    }
    private var graphBackground: some View{
        VStack{
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    private var graphYAxis: some View{
        VStack{
            Text(maxY.formattedWithAbbreviations())
            Spacer()
            Text(((maxY + minY) / 2).formattedWithAbbreviations())
            Spacer()
            Text(minY.formattedWithAbbreviations())
        }
    }
    private var graphDateLabel: some View{
        HStack{
            Text(startingDate.asShortDateString())
            Spacer()
            Text(endingDate.asShortDateString())
        }
    }
}
