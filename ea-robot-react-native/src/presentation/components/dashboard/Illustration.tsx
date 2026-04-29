import React from 'react';
import { View, StyleSheet } from 'react-native';
import LottieView from 'lottie-react-native';
import { MotiView } from 'moti';
import { Animations } from '../../../../assets/animations';

interface IllustrationProps {
  isConnected: boolean;
  isMoving: boolean;
}

export const Illustration = ({ isConnected, isMoving }: IllustrationProps) => {
  return (
    <View style={styles.container}>
      <AnimatePresence>
        {isConnected && (
          <MotiView
            from={{ opacity: 0, scale: 0.6 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.6 }}
            style={styles.glowContainer}
          >
            <MotiView
              from={{ scale: 1, opacity: 0.5 }}
              animate={{ scale: 1.5, opacity: 0 }}
              transition={{
                loop: true,
                type: 'timing',
                duration: 2000,
              }}
              style={[styles.glow, { backgroundColor: isMoving ? 'rgba(56, 189, 248, 0.2)' : 'rgba(74, 222, 128, 0.2)' }]}
            />
            <View style={[styles.glow, { backgroundColor: isMoving ? 'rgba(56, 189, 248, 0.15)' : 'rgba(74, 222, 128, 0.15)' }]} />
          </MotiView>
        )}
      </AnimatePresence>
      <LottieView
        source={
          !isConnected 
            ? Animations.welcome 
            : isMoving 
              ? Animations.moving 
              : Animations.idle
        }
        autoPlay
        loop
        style={styles.lottie}
      />
    </View>
  );
};

import { AnimatePresence } from 'moti';

const styles = StyleSheet.create({
  container: {
    height: 300,
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: 10,
  },
  lottie: {
    width: '100%',
    height: '100%',
  },
  glowContainer: {
    position: 'absolute',
    width: 250,
    height: 250,
    alignItems: 'center',
    justifyContent: 'center',
  },
  glow: {
    position: 'absolute',
    width: 180,
    height: 180,
    borderRadius: 90,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 40,
    elevation: 20,
  },
});
