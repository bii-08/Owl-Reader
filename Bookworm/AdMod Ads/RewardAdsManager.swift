//
//  RewardedAdView.swift
//  Bookworm
//
//  Created by LUU THANH TAM on 2024/06/01.
//

import Foundation
import GoogleMobileAds

class RewardAdsManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    
    // Properties
    var rewardLoaded: Bool = false
    var rewardAd: GADRewardedAd?
    
    override init() {
        super.init()
    }
    
    // Load reward ads
    func loadAd() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest()) { ad, error in
            if let error  = error {
                print("Failed to load rewardAd with error: \(error.localizedDescription)")
                //self.rewardLoaded = false
                return
            }
            print("Successfully loaded ad")
            //self.rewardLoaded = true
            self.rewardAd = ad
            self.rewardAd?.fullScreenContentDelegate = self
        }
    }
    
    // Display reward ads
    func showAd() {
  
        guard let root = UIApplication.shared.keyWindowPresentedController else { return }
        if let ad = rewardAd {
            ad.present(fromRootViewController: root) {
                print("You earned a reward")
                self.rewardLoaded = true
            }
        } else {
            print("Ad wasn't ready")
           // self.rewardLoaded = false
            self.loadAd()
        }
    }
    
    
}
