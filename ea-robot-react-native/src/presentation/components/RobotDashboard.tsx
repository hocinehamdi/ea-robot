import React, { useEffect } from 'react';
import { StyleSheet, View, StatusBar, TouchableOpacity, Text, ActivityIndicator, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LinearGradient } from 'expo-linear-gradient';
import { MotiView, AnimatePresence } from 'moti';
import { useRobotStore } from '../state/useRobotStore';
import { useDeviceTelemetry } from '../hooks/useDeviceTelemetry';
import { useRobotTelemetry } from '../hooks/useRobotTelemetry';
import { Colors } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { Header } from './dashboard/Header';
import { Illustration } from './dashboard/Illustration';
import { TelemetryPanel } from './dashboard/TelemetryPanel';
import { ControlPad } from './dashboard/ControlPad';
import { router } from 'expo-router';
import * as Haptics from 'expo-haptics';

export const RobotDashboard = () => {
  const colorScheme = useColorScheme() ?? 'dark';
  const theme = Colors[colorScheme];
  
  const { 
    robot, 
    loading,
    fetchStatus, 
    connect, 
    disconnect, 
    move, 
    stop, 
    setDeviceThermalState 
  } = useRobotStore();
  
  const { thermalState: deviceThermalState } = useDeviceTelemetry();
  
  // Start real-time telemetry
  useRobotTelemetry();

  useEffect(() => {
    fetchStatus();
  }, [fetchStatus]);

  useEffect(() => {
    if (deviceThermalState) {
      setDeviceThermalState(deviceThermalState);
    }
  }, [deviceThermalState, setDeviceThermalState]);

  const handleConnect = async () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    await connect();
  };

  const handleDisconnect = async () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    await disconnect();
  };

  const isConnected = robot?.connected ?? false;
  const isMoving = robot?.moving ?? false;
  const batteryLevel = robot?.battery ?? 0;
  const robotThermalState = robot?.thermalState ?? 'NOMINAL';

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" />
      <LinearGradient
        colors={theme.gradient || ['#0F2027', '#203A43', '#2C5364']}
        style={StyleSheet.absoluteFill}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      />
      
      <SafeAreaView style={styles.safeArea}>
        <Header 
          connected={isConnected} 
          onDisconnect={handleDisconnect}
          onMonitorPress={() => router.push('/explore')} 
        />

        <View style={styles.mainContent}>
          <Illustration 
            isConnected={isConnected} 
            isMoving={isMoving} 
          />

          <View>
            <TelemetryPanel 
              battery={batteryLevel}
              robotStatus={robotThermalState}
              deviceStatus={deviceThermalState}
            />

            <AnimatePresence exitBeforeEnter>
              {!isConnected ? (
                <MotiView
                  key="connect-view"
                  from={{ opacity: 0, translateY: 20 }}
                  animate={{ opacity: 1, translateY: 0 }}
                  exit={{ opacity: 0, translateY: 20 }}
                  style={styles.controlContainer}
                >
                  <Text style={styles.sectionLabel}>CONNECTION INTERFACE</Text>
                  <TouchableOpacity 
                    onPress={handleConnect}
                    activeOpacity={0.7}
                    disabled={loading}
                    style={styles.connectButtonWrapper}
                  >
                    <MotiView
                      animate={{
                        scale: loading ? 0.98 : 1,
                        backgroundColor: loading ? 'rgba(56, 189, 248, 0.5)' : theme.tint,
                      }}
                      style={styles.connectButton}
                    >
                      <LinearGradient
                        colors={['rgba(255,255,255,0.3)', 'transparent']}
                        style={StyleSheet.absoluteFill}
                        start={{ x: 0, y: 0 }}
                        end={{ x: 0, y: 1 }}
                      />
                      {loading ? (
                        <ActivityIndicator color="#FFF" />
                      ) : (
                        <Text style={styles.connectButtonText}>INITIALIZE NEURAL LINK</Text>
                      )}
                    </MotiView>
                  </TouchableOpacity>
                </MotiView>
              ) : (
                <MotiView
                  key="control-view"
                  from={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  style={styles.controlContainer}
                >
                  <ControlPad 
                    isMoving={isMoving}
                    onMove={move}
                    onStop={stop}
                    disabled={!isConnected || loading}
                  />
                </MotiView>
              )}
            </AnimatePresence>
          </View>
        </View>

        <AnimatePresence>
          {loading && (
            <MotiView
              from={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              style={styles.loadingOverlay}
            >
              <View style={styles.loadingCard}>
                <ActivityIndicator size="large" color={theme.tint} />
                <Text style={[styles.loadingText, { color: '#FFF' }]}>ESTABLISHING SYNC...</Text>
              </View>
            </MotiView>
          )}
        </AnimatePresence>
      </SafeAreaView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  mainContent: {
    flex: 1,
    justifyContent: 'space-between',
    paddingBottom: 20,
  },
  controlContainer: {
    paddingHorizontal: 24,
    width: '100%',
    alignItems: 'center',
  },
  sectionLabel: {
    color: 'rgba(255,255,255,0.3)',
    fontSize: 10,
    fontWeight: '900',
    letterSpacing: 2,
    marginBottom: 16,
    alignSelf: 'center',
  },
  connectButtonWrapper: {
    width: '100%',
    height: 64,
  },
  connectButton: {
    width: '100%',
    height: '100%',
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
    overflow: 'hidden',
    ...Platform.select({
      ios: {
        shadowColor: '#38BDF8',
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.5,
        shadowRadius: 15,
      },
      android: {
        elevation: 12,
      }
    })
  },
  connectButtonText: {
    color: '#FFF',
    fontSize: 14,
    fontWeight: '900',
    letterSpacing: 1.5,
  },
  loadingOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0,0,0,0.6)',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 100,
  },
  loadingCard: {
    padding: 30,
    borderRadius: 32,
    backgroundColor: 'rgba(15, 32, 39, 0.95)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.1)',
    alignItems: 'center',
    gap: 20,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 20 },
        shadowOpacity: 0.5,
        shadowRadius: 30,
      },
      android: {
        elevation: 20,
      }
    })
  },
  loadingText: {
    fontSize: 11,
    fontWeight: '900',
    letterSpacing: 3,
  },
});
