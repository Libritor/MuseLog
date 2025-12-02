import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/eeg_sample.dart';
import '../../data/models/band_power_sample.dart';
import '../../data/models/fnirs_sample.dart';
import '../../data/models/imu_sample.dart';
import '../../utils/constants.dart';
import 'muse_providers.dart';

// ===== CHART DATA MODELS =====

/// Data point for charts
class ChartDataPoint {
  final DateTime timestamp;
  final double value;

  ChartDataPoint(this.timestamp, this.value);
}

// ===== EEG CHART DATA =====

/// EEG chart data for a specific device and electrode
class EEGChartData {
  final List<ChartDataPoint> tp9Data;
  final List<ChartDataPoint> af7Data;
  final List<ChartDataPoint> af8Data;
  final List<ChartDataPoint> tp10Data;

  EEGChartData({
    required this.tp9Data,
    required this.af7Data,
    required this.af8Data,
    required this.tp10Data,
  });

  EEGChartData.empty()
      : tp9Data = [],
        af7Data = [],
        af8Data = [],
        tp10Data = [];
}

/// Maintains EEG chart data for a device
class EEGChartDataNotifier extends StateNotifier<EEGChartData> {
  EEGChartDataNotifier() : super(EEGChartData.empty());

  void addSample(EEGSample sample) {
    final newState = EEGChartData(
      tp9Data: [
        ...state.tp9Data,
        if (sample.tp9Raw != null)
          ChartDataPoint(sample.timestamp, sample.tp9Raw!),
      ],
      af7Data: [
        ...state.af7Data,
        if (sample.af7Raw != null)
          ChartDataPoint(sample.timestamp, sample.af7Raw!),
      ],
      af8Data: [
        ...state.af8Data,
        if (sample.af8Raw != null)
          ChartDataPoint(sample.timestamp, sample.af8Raw!),
      ],
      tp10Data: [
        ...state.tp10Data,
        if (sample.tp10Raw != null)
          ChartDataPoint(sample.timestamp, sample.tp10Raw!),
      ],
    );

    // Keep only recent data
    state = _trimData(newState, Constants.maxEEGDataPoints);
  }

  EEGChartData _trimData(EEGChartData data, int maxPoints) {
    return EEGChartData(
      tp9Data: data.tp9Data.length > maxPoints
          ? data.tp9Data.sublist(data.tp9Data.length - maxPoints)
          : data.tp9Data,
      af7Data: data.af7Data.length > maxPoints
          ? data.af7Data.sublist(data.af7Data.length - maxPoints)
          : data.af7Data,
      af8Data: data.af8Data.length > maxPoints
          ? data.af8Data.sublist(data.af8Data.length - maxPoints)
          : data.af8Data,
      tp10Data: data.tp10Data.length > maxPoints
          ? data.tp10Data.sublist(data.tp10Data.length - maxPoints)
          : data.tp10Data,
    );
  }

  void clear() {
    state = EEGChartData.empty();
  }
}

/// EEG chart data provider for a specific device
final eegChartDataProvider = StateNotifierProvider.family<EEGChartDataNotifier, EEGChartData, String>(
  (ref, deviceId) {
    final notifier = EEGChartDataNotifier();
    
    // Subscribe to EEG stream for this device
    ref.listen<AsyncValue<EEGSample>>(
      eegStreamForDeviceProvider(deviceId),
      (previous, next) {
        next.whenData((sample) => notifier.addSample(sample));
      },
    );
    
    return notifier;
  },
);

// ===== BAND POWER CHART DATA =====

/// Band power chart data for one electrode
class BandPowerChartData {
  final List<ChartDataPoint> deltaData;
  final List<ChartDataPoint> thetaData;
  final List<ChartDataPoint> alphaData;
  final List<ChartDataPoint> betaData;
  final List<ChartDataPoint> gammaData;

  BandPowerChartData({
    required this.deltaData,
    required this.thetaData,
    required this.alphaData,
    required this.betaData,
    required this.gammaData,
  });

  BandPowerChartData.empty()
      : deltaData = [],
        thetaData = [],
        alphaData = [],
        betaData = [],
        gammaData = [];
}

/// Maintains band power chart data for a device and electrode
class BandPowerChartDataNotifier extends StateNotifier<BandPowerChartData> {
  final String electrode; // 'TP9', 'AF7', 'AF8', or 'TP10'
  final bool isAbsolute; // true for absolute, false for relative

  BandPowerChartDataNotifier(this.electrode, this.isAbsolute)
      : super(BandPowerChartData.empty());

  void addSample(BandPowerSample sample) {
    double? getDelta() {
      switch (electrode) {
        case 'TP9':
          return isAbsolute ? sample.tp9DeltaAbsolute : sample.tp9DeltaRelative;
        case 'AF7':
          return isAbsolute ? sample.af7DeltaAbsolute : sample.af7DeltaRelative;
        case 'AF8':
          return isAbsolute ? sample.af8DeltaAbsolute : sample.af8DeltaRelative;
        case 'TP10':
          return isAbsolute ? sample.tp10DeltaAbsolute : sample.tp10DeltaRelative;
        default:
          return null;
      }
    }

    double? getTheta() {
      switch (electrode) {
        case 'TP9':
          return isAbsolute ? sample.tp9ThetaAbsolute : sample.tp9ThetaRelative;
        case 'AF7':
          return isAbsolute ? sample.af7ThetaAbsolute : sample.af7ThetaRelative;
        case 'AF8':
          return isAbsolute ? sample.af8ThetaAbsolute : sample.af8ThetaRelative;
        case 'TP10':
          return isAbsolute ? sample.tp10ThetaAbsolute : sample.tp10ThetaRelative;
        default:
          return null;
      }
    }

    double? getAlpha() {
      switch (electrode) {
        case 'TP9':
          return isAbsolute ? sample.tp9AlphaAbsolute : sample.tp9AlphaRelative;
        case 'AF7':
          return isAbsolute ? sample.af7AlphaAbsolute : sample.af7AlphaRelative;
        case 'AF8':
          return isAbsolute ? sample.af8AlphaAbsolute : sample.af8AlphaRelative;
        case 'TP10':
          return isAbsolute ? sample.tp10AlphaAbsolute : sample.tp10AlphaRelative;
        default:
          return null;
      }
    }

    double? getBeta() {
      switch (electrode) {
        case 'TP9':
          return isAbsolute ? sample.tp9BetaAbsolute : sample.tp9BetaRelative;
        case 'AF7':
          return isAbsolute ? sample.af7BetaAbsolute : sample.af7BetaRelative;
        case 'AF8':
          return isAbsolute ? sample.af8BetaAbsolute : sample.af8BetaRelative;
        case 'TP10':
          return isAbsolute ? sample.tp10BetaAbsolute : sample.tp10BetaRelative;
        default:
          return null;
      }
    }

    double? getGamma() {
      switch (electrode) {
        case 'TP9':
          return isAbsolute ? sample.tp9GammaAbsolute : sample.tp9GammaRelative;
        case 'AF7':
          return isAbsolute ? sample.af7GammaAbsolute : sample.af7GammaRelative;
        case 'AF8':
          return isAbsolute ? sample.af8GammaAbsolute : sample.af8GammaRelative;
        case 'TP10':
          return isAbsolute ? sample.tp10GammaAbsolute : sample.tp10GammaRelative;
        default:
          return null;
      }
    }

    final delta = getDelta();
    final theta = getTheta();
    final alpha = getAlpha();
    final beta = getBeta();
    final gamma = getGamma();

    final newState = BandPowerChartData(
      deltaData: [
        ...state.deltaData,
        if (delta != null) ChartDataPoint(sample.timestamp, delta),
      ],
      thetaData: [
        ...state.thetaData,
        if (theta != null) ChartDataPoint(sample.timestamp, theta),
      ],
      alphaData: [
        ...state.alphaData,
        if (alpha != null) ChartDataPoint(sample.timestamp, alpha),
      ],
      betaData: [
        ...state.betaData,
        if (beta != null) ChartDataPoint(sample.timestamp, beta),
      ],
      gammaData: [
        ...state.gammaData,
        if (gamma != null) ChartDataPoint(sample.timestamp, gamma),
      ],
    );

    state = _trimData(newState, Constants.maxBandPowerDataPoints);
  }

  BandPowerChartData _trimData(BandPowerChartData data, int maxPoints) {
    return BandPowerChartData(
      deltaData: data.deltaData.length > maxPoints
          ? data.deltaData.sublist(data.deltaData.length - maxPoints)
          : data.deltaData,
      thetaData: data.thetaData.length > maxPoints
          ? data.thetaData.sublist(data.thetaData.length - maxPoints)
          : data.thetaData,
      alphaData: data.alphaData.length > maxPoints
          ? data.alphaData.sublist(data.alphaData.length - maxPoints)
          : data.alphaData,
      betaData: data.betaData.length > maxPoints
          ? data.betaData.sublist(data.betaData.length - maxPoints)
          : data.betaData,
      gammaData: data.gammaData.length > maxPoints
          ? data.gammaData.sublist(data.gammaData.length - maxPoints)
          : data.gammaData,
    );
  }

  void clear() {
    state = BandPowerChartData.empty();
  }
}
