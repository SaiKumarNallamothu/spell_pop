import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;

  // Official Google AdMob Test Unit IDs
  static const String _androidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static const String _androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  // Production AdMob App & Unit IDs
  static const String appId = 'ca-app-pub-9215767386390942~4335980180';
  static const String bannerAdId = 'ca-app-pub-9215767386390942/8570738669';
  static const String interstitialAdId = 'ca-app-pub-9215767386390942/8241913093';
  static const String rewardedInterstitialAdId = 'ca-app-pub-9215767386390942/9012637501';
  static const String nativeAdId = 'ca-app-pub-9215767386390942/9363423070';
  static const String appOpenAdId = 'ca-app-pub-9215767386390942/5070477351';

  String get interstitialAdUnitId {
    return interstitialAdId;
  }

  String get rewardedAdUnitId {
    return rewardedInterstitialAdId;
  }

  Future<void> init() async {
    // Only initialize Mobile Ads SDK on supported mobile platforms
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      debugPrint('AdService: Mobile Ads SDK not supported on this platform.');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      loadInterstitialAd();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdService initialization error: $e');
    }
  }

  void loadInterstitialAd() {
    if (!_isInitialized || interstitialAdUnitId.isEmpty) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void loadRewardedAd() {
    if (!_isInitialized || rewardedAdUnitId.isEmpty) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void showInterstitialAd(VoidCallback onComplete) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd();
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd();
          onComplete();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('AdService: Interstitial ad not loaded. Invoking callback immediately.');
      onComplete();
    }
  }

  void showRewardedAd(VoidCallback onRewardGranted, VoidCallback onFailure) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onRewardGranted();
      });
    } else {
      debugPrint('AdService: Rewarded ad not loaded. Invoking reward callback immediately as fallback.');
      // Offline fallback: reward the user so the gameplay is not blockaded when offline
      onRewardGranted();
    }
  }
}
