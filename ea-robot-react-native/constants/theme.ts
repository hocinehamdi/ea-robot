export const Colors = {
  light: {
    text: '#11181C',
    background: '#FFFFFF',
    tint: '#007AFF',
    icon: '#687076',
    tabIconDefault: '#687076',
    tabIconSelected: '#007AFF',
    card: '#F8F9FA',
    border: '#E9ECEF',
    success: '#34C759',
    danger: '#FF3B30',
    warning: '#FFCC00',
    battery: '#34C759',
    gradient: ['#FFFFFF', '#F8F9FA', '#E9ECEF'],
  },
  dark: {
    text: '#ECEDEE',
    background: '#0F2027',
    gradient: ['#0F2027', '#203A43', '#2C5364'],
    tint: '#38BDF8',
    icon: '#94A3B8',
    tabIconDefault: '#94A3B8',
    tabIconSelected: '#38BDF8',
    card: 'rgba(255, 255, 255, 0.05)',
    border: 'rgba(255, 255, 255, 0.1)',
    success: '#4ADE80',
    danger: '#F87171',
    warning: '#FBBF24',
    battery: '#4ADE80',
  },
};

export const Spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};

export const BorderRadius = {
  sm: 4,
  md: 8,
  lg: 16,
  xl: 24,
  full: 9999,
};
export const Fonts = {
  size: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 18,
    xl: 24,
    xxl: 32,
  },
  weight: {
    normal: '400' as const,
    medium: '500' as const,
    bold: '700' as const,
  },
  rounded: 'System',
  mono: 'SpaceMono',
};
