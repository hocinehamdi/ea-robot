import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Share2, LogOut } from 'lucide-react-native';
import { Colors, Spacing } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';

interface HeaderProps {
  connected: boolean;
  onDisconnect: () => void;
  onMonitorPress: () => void;
}

export const Header = ({ connected, onDisconnect, onMonitorPress }: HeaderProps) => {
  const colorScheme = useColorScheme() ?? 'dark';
  const theme = Colors[colorScheme];

  return (
    <View style={styles.container}>
      <TouchableOpacity onPress={onMonitorPress} style={[styles.iconButton, { backgroundColor: 'rgba(255,255,255,0.05)' }]}>
        <Share2 size={20} color="#FFF" />
      </TouchableOpacity>

      <View style={[
        styles.badge, 
        { 
          backgroundColor: connected ? 'rgba(74, 222, 128, 0.1)' : 'rgba(248, 113, 113, 0.1)',
          borderColor: connected ? 'rgba(74, 222, 128, 0.4)' : 'rgba(248, 113, 113, 0.4)' 
        }
      ]}>
        <View style={[styles.dot, { backgroundColor: connected ? theme.success : theme.danger }]} />
        <Text style={[styles.badgeText, { color: connected ? theme.success : theme.danger }]}>
          {connected ? 'ONLINE' : 'OFFLINE'}
        </Text>
      </View>

      <TouchableOpacity 
        onPress={onDisconnect} 
        disabled={!connected}
        style={[
          styles.iconButton, 
          { backgroundColor: 'rgba(248, 113, 113, 0.05)', opacity: connected ? 1 : 0.3 }
        ]}
      >
        <LogOut size={20} color={theme.danger} />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
  },
  iconButton: {
    width: 44,
    height: 44,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.1)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  badge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
    gap: 8,
  },
  dot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  badgeText: {
    fontSize: 10,
    fontWeight: '900',
    letterSpacing: 1.5,
  },
});
