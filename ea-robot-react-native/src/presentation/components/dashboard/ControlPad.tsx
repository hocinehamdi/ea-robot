import React from 'react';
import { View, StyleSheet, TouchableOpacity, Platform, Text } from 'react-native';
import { ArrowUp, ArrowDown, ArrowLeft, ArrowRight, Square } from 'lucide-react-native';
import { Colors, Spacing } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';
import * as Haptics from 'expo-haptics';
import { LinearGradient } from 'expo-linear-gradient';
import { MotiView } from 'moti';

interface ControlPadProps {
  isMoving: boolean;
  onMove: () => void;
  onStop: () => void;
  disabled: boolean;
}

export const ControlPad = ({ isMoving, onMove, onStop, disabled }: ControlPadProps) => {
  const colorScheme = useColorScheme() ?? 'dark';
  const theme = Colors[colorScheme];

  const handlePress = (callback: () => void) => {
    if (disabled) return;
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    callback();
  };

  const ControlButton = ({ icon: Icon, onPress, active, color, style, large }: any) => {
    const size = large ? 80 : 68;
    const iconSize = large ? 32 : 28;
    
    return (
      <TouchableOpacity
        onPress={() => handlePress(onPress)}
        disabled={disabled}
        activeOpacity={0.7}
        style={[
          styles.buttonWrapper,
          { width: size, height: size, opacity: disabled ? 0.3 : 1 },
          style
        ]}
      >
        <MotiView
          animate={{
            scale: active ? 1.05 : 1,
            backgroundColor: active ? `${color}15` : 'rgba(255,255,255,0.03)',
          }}
          transition={{ type: 'timing', duration: 200 }}
          style={[
            styles.buttonGradient,
            { 
              borderColor: active ? color : 'rgba(255,255,255,0.1)',
              borderRadius: large ? 28 : 22,
            }
          ]}
        >
          <Icon 
            size={iconSize} 
            color={active ? color : 'rgba(255,255,255,0.6)'} 
            strokeWidth={2.5} 
          />
        </MotiView>
        
        {active && (
          <MotiView
            from={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            style={[styles.glow, { backgroundColor: color, shadowColor: color }]}
          />
        )}
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <Text style={styles.label}>DIRECTIONAL CONTROL</Text>
      
      <ControlButton 
        icon={ArrowUp} 
        onPress={onMove} 
        active={isMoving} 
        color={theme.success} 
      />

      <View style={styles.middleRow}>
        <ControlButton 
          icon={ArrowLeft} 
          onPress={onMove} 
          active={isMoving} 
          color={theme.success} 
        />

        <ControlButton 
          icon={Square} 
          onPress={onStop} 
          active={false} // No permanent glow for stop
          color={theme.danger}
          large
        />

        <ControlButton 
          icon={ArrowRight} 
          onPress={onMove} 
          active={isMoving} 
          color={theme.success} 
        />
      </View>

      <ControlButton 
        icon={ArrowDown} 
        onPress={onMove} 
        active={isMoving} 
        color={theme.success} 
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    marginVertical: Spacing.xl,
    gap: 12,
  },
  label: {
    color: 'rgba(255,255,255,0.3)',
    fontSize: 10,
    fontWeight: '900',
    letterSpacing: 2,
    marginBottom: 8,
  },
  middleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  buttonWrapper: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonGradient: {
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1.5,
    backgroundColor: 'rgba(255,255,255,0.03)',
  },
  glow: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    borderRadius: 22,
    opacity: 0.1,
    zIndex: -1,
    ...Platform.select({
      ios: {
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 1,
        shadowRadius: 20,
      },
      android: {
        elevation: 20,
      }
    })
  }
});
