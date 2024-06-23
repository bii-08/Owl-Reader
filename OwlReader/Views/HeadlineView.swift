//
//  HeadlineView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/04/30.
//

import SwiftUI
import UIKit

struct HeadlineView: View {

    var headline: Headline
    var deviceType: DeviceType
    var action: () -> ()
    
    init(headline: Headline, deviceType: DeviceType, action: @escaping () -> Void) {
        self.headline = headline
        self.deviceType = deviceType
        self.deviceType = DeviceInfo.shared.getDeviceType()
        self.action = action
    }
    var body: some View {
        
        Button {
           action()
           AnalyticsManager.shared.logEvent(name: "HomeView_BreakingNews_HeadlineClick")
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: headline.urlToImage)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: getCustomSize(for: .imageSize, deviceType: deviceType).width, maxHeight: getCustomSize(for: .imageSize, deviceType: deviceType).height)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 1)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.5))
                            .frame(maxWidth: getCustomSize(for: .imageSize, deviceType: deviceType).width, maxHeight: getCustomSize(for: .imageSize, deviceType: deviceType).height)
                            .shadow(radius: 1)
                    }
                }
                .overlay(
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color("headlineRounded"))
                            .frame(maxWidth: getCustomSize(for: .headlineRectangleSize, deviceType: deviceType).width, maxHeight: getCustomSize(for: .headlineRectangleSize, deviceType: deviceType).height)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 20,
                                    topTrailingRadius: 20
                                )
                            )
                    }
                    .overlay(
                        VStack {
                            HStack {
                                Spacer()
                                Text("     " + "\(headline.source?.name ?? "")")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: getCustomSize(for: .headlineRectangleSize, deviceType: deviceType).width, maxHeight: getCustomSize(for: .headlineRectangleSize, deviceType: deviceType).height)
                                    .background(Rectangle().fill(Color("headlineTitleRounded")))
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 0,
                                            bottomLeadingRadius: 0,
                                            bottomTrailingRadius: 0,
                                            topTrailingRadius: 20
                                        )
                                    )
                            }
                            .overlay() {
                                HStack {
                                    Text("")
                                        .padding(UIScreen.main.bounds.height <= 812 && UIScreen.main.bounds.width <= 375 ? 15 : 20)
                                    Image(headline.source?.name ?? "")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: getCustomSize(for: .icon, deviceType: deviceType).width, height: getCustomSize(for: .icon, deviceType: deviceType).height)
                                        .cornerRadius(3)
                                }
                                .padding()
                            }
                            VStack {
                                HStack {
                                    Spacer()
                                    Text(headline.title)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: getCustomSize(for: .headlineTitleSize, deviceType: deviceType).width, height: getCustomSize(for: .headlineTitleSize, deviceType: deviceType).height)
                                        .foregroundColor(.primary)
                                }
                                .padding()
                            }
                        }
                    )
                )
            }
        }
    }
    
   private func getCustomSize(for sizeType: SizeType, deviceType: DeviceType) -> CGSize {
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width

        switch deviceType {
        case .pad:
            switch sizeType {
            case .imageSize:
                return CGSize(width: 700, height: 350)
            case .headlineRectangleSize:
                return CGSize(width: 380, height: 350)
            case .headlineTitleSize:
                return CGSize(width: 320, height: 230)
            case .icon:
                return CGSize(width: 50, height: 50)
                
            }
        case .phone:
            switch sizeType {
            case .imageSize:
                if screenHeight <= 812 && screenWidth <= 375 {
                    return CGSize(width: 350, height: 180)
                } else {
                    return CGSize(width: 380, height: 200)
                }
            case .headlineRectangleSize:
                if screenHeight <= 812 && screenWidth <= 375 {
                    return CGSize(width: 180, height: 190)
                } else {
                    return CGSize(width: 190, height: 200)
                }
            case .headlineTitleSize:
                if screenHeight <= 812 && screenWidth <= 375 {
                    return CGSize(width: 150, height: 100)
                } else {
                    return CGSize(width: 160, height: 100)
                }
            case .icon:
                if screenHeight <= 812 && screenWidth <= 375 {
                    return CGSize(width: 20, height: 20)
                } else {
                    return CGSize(width: 23, height: 23)
                }
            }
        }
    }
}

//#Preview {
//    HeadlineView(headline: Headline(source: Source(name: "BBC News"),title: "BBC Gaza reporter: My struggle to keep family safe while covering the war", url: "https://www.bbc.co.uk/news/world-middle-east-68906903", urlToImage: "https://ichef.bbci.co.uk/news/1024/branded_news/977D/production/_133218783_razan_hug.jpg"), action: {})
//}
