import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Battery, Cpu, Smartphone } from 'lucide-react-native';
import { MotiView } from 'moti';
import { Colors, Spacing } from '@/constants/theme';
import { useColorScheme } from '@/hooks/use-color-scheme';

interface TelemetryPanelProps {
  battery: number;
  robotStatus: string;
  deviceStatus: string;
}

export const TelemetryPanel = ({ battery, robotStatus, deviceStatus }: TelemetryPanelProps) => {
  const colorScheme = useColorScheme() ?? 'dark';
  const theme = Colors[colorScheme];

  const getStatusColor = (status: string) => {
    const s = status.toUpperCase();
    if (s === 'NOMINAL' || s === 'STABLE') return theme.success;
    if (s === 'FAIR' || s === 'MODERATE' || s === 'WARNING') return theme.warning || '#F59E0B';
    if (s === 'CRITICAL' || s === 'EMERGENCY' || s === 'SERIOUS') return theme.danger;
    return theme.icon;
  };

  const getBatteryColor = (level: number) => {
    if (level > 50) return theme.success;
    if (level > 20) return theme.warning || '#F59E0B';
    return theme.danger;
  };

  const TelemetryItem = ({ icon: Icon, label, value, color, delay }: any) => (
    <MotiView 
      from={{ opacity: 0, translateY: 10 }}
      animate={{ opacity: 1, translateY: 0 }}
      transition={{ delay, type: 'timing', duration: 500 }}
      style={styles.column}
    >
      <View style={[styles.iconWrapper, { backgroundColor: `${color}10` }]}>
        <Icon size={20} color={color} />
      </View>
      <Text style={styles.label}>{label}</Text>
      <Text style={[styles.value, { color }]}>{value}</Text>
    </MotiView>
  );

  return (
    <View style={[styles.container, { backgroundColor: 'rgba(255,255,255,0.03)', borderColor: 'rgba(255,255,255,0.1)' }]}>
      <TelemetryItem 
        icon={Battery} 
        label="BATTERY" 
        value={`${battery}%`} 
        color={getBatteryColor(battery)} 
        delay={100}
      />
      
      <View style={styles.divider} />

      <TelemetryItem 
        icon={Cpu} 
        label="ROBOT" 
        value={robotStatus} 
        color={getStatusColor(robotStatus)} 
        delay={200}
      />

      <View style={styles.divider} />

      <TelemetryItem 
        icon={Smartphone} 
        label="DEVICE" 
        value={deviceStatus} 
        color={getStatusColor(deviceStatus)} 
        delay={300}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    marginHorizontal: Spacing.lg,
    paddingVertical: 24,
    paddingHorizontal: 12,
    borderRadius: 24,
    borderWidth: 1,
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 10,
  },
  column: {
    flex: 1,
    alignItems: 'center',
    gap: 8,
  },
  iconWrapper: {
    width: 40,
    height: 40,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 4,
  },
  divider: {
    width: 1,
    height: 40,
    backgroundColor: 'rgba(255,255,255,0.05)',
  },
  label: {
    fontSize: 9,
    fontWeight: '900',
    letterSpacing: 1.5,
    color: 'rgba(255,255,255,0.3)',
  },
  value: {
    fontSize: 12,
    fontWeight: 'bold',
    letterSpacing: 0.5,
  },
});
